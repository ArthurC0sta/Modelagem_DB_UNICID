"""Gera o DER conceitual revisado da QORE em PNG.

O desenho segue a notação conceitual solicitada: entidades em retângulos,
relacionamentos em losangos, identificadores sublinhados e cardinalidades
mínima/máxima nas duas extremidades. Não exibe chaves estrangeiras.
"""

from pathlib import Path
from textwrap import wrap

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "DER_QORE_CICLO_SERVICOS.png"
FLOW_OUTPUT = ROOT / "FLUXO_CICLO_SERVICOS_QORE.png"
ARCH_OUTPUT = ROOT / "ORIGEM_E_ARQUITETURA_DADOS_QORE.png"

WIDTH, HEIGHT = 4000, 2700
BG, PAPER = "#F5F2EA", "#FFFDF8"
NAVY, BLUE, GOLD = "#2E2044", "#315A7D", "#B48534"
INK, MUTED, LINE = "#211A2B", "#665F6D", "#786C83"
SOFT_BLUE, SOFT_GOLD = "#E8F0F5", "#F5EBD8"

REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(BOLD if bold else REGULAR, size)


TITLE = font(58, True)
SUBTITLE = font(28)
ENTITY_TITLE = font(25, True)
ATTRIBUTE = font(19)
RELATIONSHIP = font(18, True)
CARDINALITY = font(20, True)
NOTE = font(19)


def centered_text(draw: ImageDraw.ImageDraw, box, value: str, text_font, fill=INK, width=30):
    lines = []
    for paragraph in value.split("\n"):
        lines.extend(wrap(paragraph, width=width) or [""])
    heights = [draw.textbbox((0, 0), line, font=text_font)[3] for line in lines]
    total = sum(heights) + max(0, len(lines) - 1) * 5
    y = (box[1] + box[3] - total) / 2
    for line, line_height in zip(lines, heights):
        bounds = draw.textbbox((0, 0), line, font=text_font)
        x = (box[0] + box[2] - (bounds[2] - bounds[0])) / 2
        draw.text((x, y), line, font=text_font, fill=fill)
        y += line_height + 5


def entity(draw: ImageDraw.ImageDraw, box, name: str, attributes: list[str], technical=False):
    x1, y1, x2, y2 = box
    header = BLUE if technical else NAVY
    draw.rounded_rectangle(box, radius=14, fill=PAPER, outline=header, width=4)
    draw.rectangle((x1, y1, x2, y1 + 52), fill=header)
    centered_text(draw, (x1, y1, x2, y1 + 52), name, ENTITY_TITLE, fill=PAPER, width=34)

    y = y1 + 67
    for index, raw in enumerate(attributes):
        identifier = raw.startswith("_")
        value = raw[1:] if identifier else raw
        draw.text((x1 + 18, y), value, font=ATTRIBUTE, fill=INK)
        if identifier:
            bounds = draw.textbbox((x1 + 18, y), value, font=ATTRIBUTE)
            draw.line((bounds[0], bounds[3] + 2, bounds[2], bounds[3] + 2), fill=INK, width=2)
        y += 29


def diamond(draw: ImageDraw.ImageDraw, center, label: str, technical=False, width=155, height=90):
    x, y = center
    points = [(x, y - height // 2), (x + width // 2, y), (x, y + height // 2), (x - width // 2, y)]
    fill = SOFT_BLUE if technical else SOFT_GOLD
    outline = BLUE if technical else GOLD
    draw.polygon(points, fill=fill)
    draw.line(points + [points[0]], fill=outline, width=4)
    centered_text(draw, (x - width // 2 + 8, y - height // 2 + 6, x + width // 2 - 8, y + height // 2 - 6), label, RELATIONSHIP, width=16)


def relation(draw: ImageDraw.ImageDraw, start, end, label: str, start_card: str, end_card: str, technical=False):
    sx, sy = start
    ex, ey = end
    mx, my = (sx + ex) // 2, (sy + ey) // 2
    color = BLUE if technical else LINE
    draw.line((sx, sy, mx - 80, my), fill=color, width=4)
    draw.line((mx + 80, my, ex, ey), fill=color, width=4)
    diamond(draw, (mx, my), label, technical=technical)
    draw.text((sx + (12 if ex >= sx else -70), sy - 29), start_card, font=CARDINALITY, fill=color)
    draw.text((ex + (-66 if ex >= sx else 12), ey - 29), end_card, font=CARDINALITY, fill=color)


def vertical_relation(draw: ImageDraw.ImageDraw, start, end, label: str, start_card: str, end_card: str, technical=False):
    sx, sy = start
    ex, ey = end
    mx, my = (sx + ex) // 2, (sy + ey) // 2
    color = BLUE if technical else LINE
    draw.line((sx, sy, mx, my - 50), fill=color, width=4)
    draw.line((mx, my + 50, ex, ey), fill=color, width=4)
    diamond(draw, (mx, my), label, technical=technical, width=160, height=95)
    draw.text((sx + 12, sy + 8), start_card, font=CARDINALITY, fill=color)
    draw.text((ex + 12, ey - 34), end_card, font=CARDINALITY, fill=color)


def associative(draw: ImageDraw.ImageDraw, box, relationship_name: str, attributes: list[str], technical=False):
    x1, y1, x2, y2 = box
    outline = BLUE if technical else NAVY
    draw.rectangle(box, outline=outline, width=4)
    diamond(draw, ((x1 + x2) // 2, y1 + 67), relationship_name, technical=technical, width=190, height=92)
    y = y1 + 130
    for attribute in attributes:
        draw.ellipse((x1 + 20, y, x1 + 36, y + 16), fill=PAPER, outline=outline, width=2)
        draw.text((x1 + 48, y - 3), attribute, font=ATTRIBUTE, fill=INK)
        y += 29


def associative_link(draw: ImageDraw.ImageDraw, start, end, start_card: str, end_card: str, technical=False):
    color = BLUE if technical else LINE
    draw.line((start, end), fill=color, width=4)
    sx, sy = start
    ex, ey = end
    draw.text((sx + (12 if ex >= sx else -70), sy - 29), start_card, font=CARDINALITY, fill=color)
    draw.text((ex + (-66 if ex >= sx else 12), ey - 29), end_card, font=CARDINALITY, fill=color)


def build():
    image = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(image)

    draw.text((70, 45), "DER conceitual revisado — Ciclo de Serviços da QORE", font=TITLE, fill=NAVY)
    draw.text((72, 118), "Modelo proposto: do cadastro do cliente à finalização do projeto, com o subsistema Accenture C6", font=SUBTITLE, fill=MUTED)
    draw.rectangle((70, 170, WIDTH - 70, 176), fill=GOLD)

    boxes = {
        "CLIENTE": (70, 260, 490, 470),
        "CHAMADO": (690, 240, 1150, 500),
        "REUNIAO": (1340, 260, 1760, 470),
        "ESCOPO": (1950, 240, 2390, 500),
        "PROPOSTA": (2580, 240, 3020, 500),
        "CONTRATO_SERVICO": (3210, 240, 3910, 500),
        "FUNCIONARIO": (70, 830, 500, 1060),
        "PROJETO": (1420, 760, 1960, 1060),
        "ENTREGA": (2580, 790, 3060, 1050),
        "AUTOMACAO": (120, 1450, 560, 1690),
        "EXECUCAO": (760, 1430, 1220, 1710),
        "CONTRATO_PROCESSADO": (1430, 1430, 1970, 1710),
        "EVENTO_EXECUCAO": (760, 2130, 1240, 2390),
        "LOTE_IMPORTACAO": (3040, 1430, 3520, 1710),
        "INSTANCIA_IMPORTACAO": (3040, 2130, 3520, 2390),
    }

    entity(draw, boxes["CLIENTE"], "CLIENTE", ["_id_cliente", "nome empresarial", "identificação", "contatos", "situação"])
    entity(draw, boxes["CHAMADO"], "CHAMADO", ["_id_chamado", "tipo e prioridade", "descrição", "abertura e prazo", "situação e solução"])
    entity(draw, boxes["REUNIAO"], "REUNIÃO", ["_id_reuniao", "data e horário", "participantes", "pauta", "decisões"])
    entity(draw, boxes["ESCOPO"], "ESCOPO", ["_id_escopo", "versão", "requisitos", "entregas e limites", "prazo e situação"])
    entity(draw, boxes["PROPOSTA"], "PROPOSTA", ["_id_proposta", "envio e validade", "condições", "situação", "decisão do cliente"])
    entity(draw, boxes["CONTRATO_SERVICO"], "CONTRATO DE SERVIÇO", ["_id_contrato_servico", "objeto", "início e fim", "situação", "responsáveis"])
    entity(draw, boxes["FUNCIONARIO"], "FUNCIONÁRIO", ["_id_funcionario", "nome", "função", "contato corporativo", "situação"])
    entity(draw, boxes["PROJETO"], "PROJETO", ["_id_projeto", "nome e objetivo", "datas previstas/reais", "situação", "finalização/cancelamento"])
    entity(draw, boxes["ENTREGA"], "ENTREGA", ["_id_entrega", "versão e descrição", "data e responsável", "evidência", "aceite/ressalva/rejeição"])
    entity(draw, boxes["AUTOMACAO"], "AUTOMAÇÃO", ["_id_automacao", "nome", "descrição", "situação"], technical=True)
    entity(draw, boxes["EXECUCAO"], "EXECUÇÃO", ["_id_execucao", "tipo de consulta", "início e fim", "estado", "totais e duração"], technical=True)
    entity(draw, boxes["CONTRATO_PROCESSADO"], "CONTRATO PROCESSADO", ["_id_contrato_processado", "número do contrato", "estado", "responsável operacional", "tempos e erro"], technical=True)
    entity(draw, boxes["EVENTO_EXECUCAO"], "EVENTO DE EXECUÇÃO", ["_id_evento", "tipo", "mensagem", "momento", "responsável operacional"], technical=True)
    entity(draw, boxes["LOTE_IMPORTACAO"], "LOTE DE IMPORTAÇÃO", ["_id_lote", "arquivo", "estado", "totais", "erro"], technical=True)
    entity(draw, boxes["INSTANCIA_IMPORTACAO"], "INSTÂNCIA DE IMPORTAÇÃO", ["_id_instancia", "ticket", "estado", "retorno", "atualização e fim"], technical=True)

    relation(draw, (490, 365), (690, 365), "abre", "(0,n)", "(1,1)")
    relation(draw, (1150, 365), (1340, 365), "possui", "(0,n)", "(1,1)")
    relation(draw, (1760, 365), (1950, 365), "define", "(0,n)", "(1,1)")
    relation(draw, (2390, 365), (2580, 365), "fundamenta", "(0,n)", "(1,1)")
    relation(draw, (3020, 365), (3210, 365), "gera", "(0,1)", "(1,1)")
    vertical_relation(draw, (3560, 500), (1690, 760), "abre", "(0,n)", "(1,1)")
    vertical_relation(draw, (860, 500), (1500, 760), "refere-se", "(0,1)", "(0,n)")
    vertical_relation(draw, (1080, 500), (2660, 790), "relata", "(0,1)", "(0,n)")
    relation(draw, (1960, 920), (2580, 920), "produz", "(0,n)", "(1,1)")

    associative(draw, (680, 760, 1180, 1080), "ALOCA", ["função", "início e fim", "dedicação", "responsabilidade"])
    associative_link(draw, (500, 945), (680, 945), "(0,n)", "(1,1)")
    associative_link(draw, (1180, 945), (1420, 945), "(1,1)", "(1,n)")

    vertical_relation(draw, (1690, 1060), (340, 1450), "possui", "(0,n)", "(1,1)", technical=True)
    relation(draw, (560, 1570), (760, 1570), "gera", "(0,n)", "(1,1)", technical=True)
    relation(draw, (1220, 1570), (1430, 1570), "processa", "(0,n)", "(1,1)", technical=True)
    vertical_relation(draw, (990, 1710), (1000, 2130), "registra", "(0,n)", "(1,1)", technical=True)
    vertical_relation(draw, (1700, 1710), (1150, 2130), "contextualiza", "(0,n)", "(0,1)", technical=True)

    associative(draw, (2470, 1830, 2950, 2110), "PARTICIPA", ["situação", "momento da confirmação"], technical=True)
    associative_link(draw, (1700, 1710), (2590, 1830), "(0,n)", "(1,1)", technical=True)
    associative_link(draw, (3280, 1710), (2830, 1830), "(1,n)", "(1,1)", technical=True)
    vertical_relation(draw, (3280, 1710), (3280, 2130), "acompanha", "(0,n)", "(1,1)", technical=True)

    draw.rounded_rectangle((70, 2480, 3910, 2615), radius=16, fill=PAPER, outline=GOLD, width=3)
    draw.text((100, 2510), "LEGENDA", font=ENTITY_TITLE, fill=NAVY)
    draw.text((300, 2512), "Identificador sublinhado • losango = relacionamento • retângulo envolvendo losango = entidade associativa", font=NOTE, fill=INK)
    draw.text((300, 2550), "Cardinalidade exibida como (mínimo, máximo) em ambos os lados • sem chaves estrangeiras no modelo conceitual", font=NOTE, fill=INK)
    draw.text((300, 2588), "Status: modelo proposto para a revisão da Entrega 1; criado com Python/Pillow seguindo a notação do brModelo.", font=NOTE, fill=MUTED)

    image.save(OUTPUT, quality=96)
    print(OUTPUT)


def process_box(draw, box, number, title, detail, technical=False):
    x1, y1, x2, y2 = box
    color = BLUE if technical else NAVY
    fill = SOFT_BLUE if technical else PAPER
    draw.rounded_rectangle(box, radius=22, fill=fill, outline=color, width=4)
    draw.ellipse((x1 + 20, y1 + 22, x1 + 76, y1 + 78), fill=color)
    centered_text(draw, (x1 + 20, y1 + 22, x1 + 76, y1 + 78), str(number), font(24, True), fill=PAPER)
    draw.text((x1 + 95, y1 + 21), title, font=font(25, True), fill=color)
    lines = wrap(detail, width=38)
    y = y1 + 65
    for line in lines[:3]:
        draw.text((x1 + 95, y), line, font=font(18), fill=MUTED)
        y += 25


def arrow(draw, start, end, color=LINE):
    draw.line((start, end), fill=color, width=5)
    ex, ey = end
    sx, sy = start
    if abs(ex - sx) >= abs(ey - sy):
        direction = 1 if ex > sx else -1
        points = [(ex, ey), (ex - 18 * direction, ey - 11), (ex - 18 * direction, ey + 11)]
    else:
        direction = 1 if ey > sy else -1
        points = [(ex, ey), (ex - 11, ey - 18 * direction), (ex + 11, ey - 18 * direction)]
    draw.polygon(points, fill=color)


def build_flow():
    image = Image.new("RGB", (3300, 1750), BG)
    draw = ImageDraw.Draw(image)
    draw.text((70, 45), "Fluxo do Ciclo de Serviços da QORE", font=TITLE, fill=NAVY)
    draw.text((72, 118), "Do cadastro do cliente à finalização do projeto e ao suporte", font=SUBTITLE, fill=MUTED)
    draw.rectangle((70, 170, 3230, 176), fill=GOLD)

    steps = [
        ((70, 260, 590, 430), 1, "Cadastro do cliente", "Identificação, contatos autorizados e situação", False),
        ((720, 260, 1240, 430), 2, "Abertura do chamado", "Necessidade, prioridade, prazo e solicitante", False),
        ((1370, 260, 1890, 430), 3, "Análise", "Viabilidade, contexto, dúvidas e responsável", False),
        ((2020, 260, 2540, 430), 4, "Reunião", "Participantes, pauta, decisões e pendências", False),
        ((2670, 260, 3190, 430), 5, "Definição do escopo", "Requisitos, entregas, limites e prazo", False),
        ((2670, 700, 3190, 870), 6, "Proposta", "Condições, validade e decisão do cliente", False),
        ((2020, 700, 2540, 870), 7, "Contratação", "Objeto, vigência e responsáveis", False),
        ((1370, 700, 1890, 870), 8, "Abertura do projeto", "Objetivo, planejamento, situação e responsável", False),
        ((720, 700, 1240, 870), 9, "Alocação da equipe", "Funções, período, dedicação e responsabilidades", False),
        ((70, 700, 590, 870), 10, "Desenvolvimento", "Execução, decisões, ocorrências e automações", True),
        ((70, 1140, 590, 1310), 11, "Entrega", "Versão, evidência e responsável", False),
        ((720, 1140, 1240, 1310), 12, "Aceite do cliente", "Aceite, ressalva ou rejeição registrada", False),
        ((1370, 1140, 1890, 1310), 13, "Finalização", "Conclusão ou cancelamento com histórico", False),
        ((2020, 1140, 2540, 1310), 14, "Suporte", "Dúvidas, incidentes, correções e melhorias", False),
    ]
    for item in steps:
        process_box(draw, *item)

    for start, end in [
        ((590, 345), (720, 345)), ((1240, 345), (1370, 345)), ((1890, 345), (2020, 345)), ((2540, 345), (2670, 345)),
        ((330, 870), (330, 1140)), ((590, 1225), (720, 1225)), ((1240, 1225), (1370, 1225)), ((1890, 1225), (2020, 1225)),
    ]:
        arrow(draw, start, end, BLUE if start[1] == 785 or start == (330, 870) else LINE)

    draw.rounded_rectangle((70, 1460, 3190, 1640), radius=18, fill=PAPER, outline=GOLD, width=3)
    draw.text((105, 1495), "PONTOS DE CONTROLE", font=font(25, True), fill=NAVY)
    notes = [
        "Nenhum contrato sem proposta aprovada", "Nenhum projeto sem responsável", "Nenhuma conclusão sem entrega e decisão do cliente",
        "Suporte preserva vínculo com cliente, contrato, projeto e entrega", "Automações permanecem ligadas ao projeto que as originou",
    ]
    x, y = 105, 1540
    for index, note in enumerate(notes):
        draw.ellipse((x, y + 5, x + 12, y + 17), fill=GOLD)
        draw.text((x + 24, y), note, font=NOTE, fill=INK)
        x += 610
        if index == 3:
            x, y = 105, y + 42

    image.save(FLOW_OUTPUT, quality=96)
    print(FLOW_OUTPUT)


def architecture_box(draw, box, title, detail, external=False, technical=False):
    x1, y1, x2, y2 = box
    color = GOLD if external else (BLUE if technical else NAVY)
    fill = SOFT_GOLD if external else (SOFT_BLUE if technical else PAPER)
    draw.rounded_rectangle(box, radius=22, fill=fill, outline=color, width=4)
    centered_text(draw, (x1 + 20, y1 + 15, x2 - 20, y1 + 80), title, font(27, True), fill=color, width=32)
    centered_text(draw, (x1 + 30, y1 + 75, x2 - 30, y2 - 15), detail, font(19), fill=MUTED, width=44)


def build_architecture():
    image = Image.new("RGB", (3300, 1900), BG)
    draw = ImageDraw.Draw(image)
    draw.text((70, 45), "Origem, responsabilidade e arquitetura dos dados", font=TITLE, fill=NAVY)
    draw.text((72, 118), "Do cliente e da contratação à execução técnica, entrega e suporte", font=SUBTITLE, fill=MUTED)
    draw.rectangle((70, 170, 3230, 176), fill=GOLD)

    boxes = [
        ((80, 260, 600, 480), "CLIENTE", "Origina chamados, participa de reuniões, decide propostas e avalia entregas.", True, False),
        ((760, 260, 1420, 480), "GESTÃO DE SERVIÇOS QORE", "Registra cliente, chamado, reunião, escopo, proposta e contrato.", False, False),
        ((1580, 260, 2240, 480), "GESTÃO DE PROJETOS", "Controla projeto, equipe, desenvolvimento, entrega e finalização.", False, False),
        ((2400, 260, 3220, 480), "EQUIPE QORE", "Comercial, gestão, desenvolvimento, suporte e auditoria por papéis.", False, False),
        ((80, 790, 600, 1010), "PORTAL C6 AUTO", "Fonte externa de contratos, parcelas, ocorrências e situações.", True, True),
        ((760, 790, 1420, 1010), "AUTOMAÇÃO ACCENTURE C6", "Autenticação, seleção, consulta, classificação e De/Para.", False, True),
        ((1580, 790, 2240, 1010), "PERSISTÊNCIA OPERACIONAL", "Execuções, contratos processados, eventos, retomada e auditoria.", False, True),
        ((2400, 790, 3220, 1010), "CSLOG", "Recebe lotes e devolve tickets/instâncias para acompanhamento.", True, True),
        ((760, 1320, 1420, 1540), "MONITORAMENTO", "Acompanha estados, falhas, progresso, lotes e tickets.", False, True),
        ((1580, 1320, 2240, 1540), "ENTREGA E ACEITE", "Disponibiliza o resultado, registra decisão e sustenta a finalização.", False, False),
        ((2400, 1320, 3220, 1540), "SUPORTE", "Mantém chamados ligados ao cliente, contrato, projeto e entrega histórica.", False, False),
    ]
    for item in boxes:
        architecture_box(draw, *item)

    connections = [
        ((600, 370), (760, 370), LINE), ((1420, 370), (1580, 370), LINE), ((2240, 370), (2400, 370), LINE),
        ((1910, 480), (1090, 790), BLUE), ((600, 900), (760, 900), BLUE), ((1420, 900), (1580, 900), BLUE), ((2240, 900), (2400, 900), BLUE),
        ((1090, 1010), (1090, 1320), BLUE), ((1910, 1010), (1910, 1320), BLUE), ((2810, 1010), (2810, 1320), BLUE),
        ((1420, 1430), (1580, 1430), LINE), ((2240, 1430), (2400, 1430), LINE),
    ]
    for start, end, color in connections:
        arrow(draw, start, end, color)

    draw.rounded_rectangle((80, 1700, 3220, 1810), radius=16, fill=PAPER, outline=GOLD, width=3)
    draw.text((115, 1730), "GOVERNANÇA", font=font(24, True), fill=NAVY)
    draw.text((360, 1732), "Dados pessoais e comerciais seguem finalidade e menor privilégio; credenciais, tokens, cookies e dados reais não integram o repositório acadêmico.", font=NOTE, fill=INK)

    image.save(ARCH_OUTPUT, quality=96)
    print(ARCH_OUTPUT)


if __name__ == "__main__":
    build()
    build_flow()
    build_architecture()
