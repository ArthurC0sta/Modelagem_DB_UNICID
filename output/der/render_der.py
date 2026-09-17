from pathlib import Path
from xml.sax.saxutils import escape

from PIL import Image, ImageDraw, ImageFont


OUT_DIR = Path(__file__).resolve().parent
WIDTH, HEIGHT = 2400, 2200

BG = "#F4F7FB"
NAVY = "#16345B"
BLUE = "#1F6FB2"
CYAN = "#18A8C9"
INK = "#17263A"
MUTED = "#5C6B7A"
LINE = "#87A0BA"
WHITE = "#FFFFFF"
ROW = "#EAF1F8"
SHADOW = "#CBD6E2"

FONT_REGULAR = "/System/Library/Fonts/Supplemental/Arial.ttf"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def font(size: int, bold: bool = False):
    return ImageFont.truetype(FONT_BOLD if bold else FONT_REGULAR, size)


TITLE_FONT = font(48, True)
SUBTITLE_FONT = font(24)
ENTITY_FONT = font(27, True)
ATTR_FONT = font(19)
ATTR_BOLD_FONT = font(19, True)
LABEL_FONT = font(18, True)
NOTE_FONT = font(18)


entities = {
    "AUTOMACAO": {
        "box": (70, 260, 530, 505),
        "attrs": [
            ("PK", "id_automacao", "INT"),
            ("UQ", "nome", "VARCHAR(100)"),
            ("", "descricao", "VARCHAR(255) NULL"),
            ("", "ativo", "BOOLEAN"),
        ],
    },
    "EXECUCAO": {
        "box": (680, 220, 1370, 865),
        "attrs": [
            ("PK", "id_execucao", "BIGINT"),
            ("FK", "id_automacao", "INT"),
            ("", "criado_em", "DATETIME"),
            ("", "iniciado_em", "DATETIME NULL"),
            ("", "finalizado_em", "DATETIME NULL"),
            ("", "status", "VARCHAR(30)"),
            ("", "total_contratos", "INT"),
            ("", "contratos_sucesso", "INT"),
            ("", "contratos_erro", "INT"),
            ("/", "qtd_workers", "INT (derivado)"),
            ("", "duracao_segundos", "INT NULL"),
            ("", "nome_execucao", "VARCHAR(100)"),
            ("", "tipo_consulta", "VARCHAR(60)"),
            ("", "horario_agendado", "TIME"),
            ("", "mensagem_erro", "TEXT NULL"),
        ],
    },
    "CONTRATO": {
        "box": (1540, 220, 2330, 865),
        "attrs": [
            ("PK", "id_contrato", "BIGINT"),
            ("FK", "id_execucao", "BIGINT"),
            ("", "id_contrato_origem", "BIGINT NULL"),
            ("", "numero_contrato", "VARCHAR(30)"),
            ("", "status", "VARCHAR(30)"),
            ("", "worker_atual", "VARCHAR(50) NULL"),
            ("", "iniciado_em", "DATETIME NULL"),
            ("", "finalizado_em", "DATETIME NULL"),
            ("", "duracao_segundos", "INT NULL"),
            ("", "qtd_parcelas", "INT"),
            ("", "qtd_ocorrencias", "INT"),
            ("", "arquivo_saida", "VARCHAR(255) NULL"),
            ("", "mensagem_erro", "TEXT NULL"),
            ("UQ", "(id_execucao, numero_contrato)", ""),
        ],
    },
    "LOTE_IMPORTACAO": {
        "box": (70, 1000, 680, 1510),
        "attrs": [
            ("PK", "id_lote", "BIGINT"),
            ("", "criado_em", "DATETIME"),
            ("", "atualizado_em", "DATETIME"),
            ("", "finalizado_em", "DATETIME NULL"),
            ("", "arquivo_importacao", "VARCHAR(255) NULL"),
            ("", "ticket_base", "VARCHAR(50)"),
            ("", "qtd_instancias", "INT"),
            ("", "total_contratos", "INT"),
            ("", "total_linhas", "INT"),
            ("", "status", "VARCHAR(30)"),
            ("", "mensagem_erro", "TEXT NULL"),
        ],
    },
    "CONTRATO_LOTE_IMPORTACAO": {
        "box": (820, 1050, 1460, 1415),
        "attrs": [
            ("PK", "id_contrato_lote", "BIGINT"),
            ("FK", "id_contrato", "BIGINT"),
            ("FK", "id_lote", "BIGINT"),
            ("", "status_importacao", "VARCHAR(30)"),
            ("", "importado_em", "DATETIME NULL"),
            ("UQ", "(id_contrato, id_lote)", ""),
        ],
    },
    "EVENTO_EXECUCAO": {
        "box": (1620, 1050, 2330, 1510),
        "attrs": [
            ("PK", "id_evento", "BIGINT"),
            ("FK", "id_execucao", "BIGINT"),
            ("FK", "id_contrato", "BIGINT NULL"),
            ("", "worker_label", "VARCHAR(50) NULL"),
            ("", "numero_contrato", "VARCHAR(30) NULL"),
            ("", "tipo_evento", "VARCHAR(60)"),
            ("", "mensagem", "TEXT NULL"),
            ("", "criado_em", "DATETIME"),
        ],
    },
    "INSTANCIA_IMPORTACAO": {
        "box": (70, 1670, 710, 2110),
        "attrs": [
            ("PK", "id_instancia", "BIGINT"),
            ("FK", "id_lote", "BIGINT"),
            ("", "numero_instancia", "INT"),
            ("", "ticket", "VARCHAR(50)"),
            ("", "status", "VARCHAR(30)"),
            ("", "status_codigo", "INT NULL"),
            ("", "informacao", "TEXT NULL"),
            ("", "mensagem_erro", "TEXT NULL"),
            ("", "atualizado_em", "DATETIME"),
            ("", "finalizado_em", "DATETIME NULL"),
            ("UQ", "(id_lote, numero_instancia)", ""),
            ("UQ", "(id_lote, ticket)", ""),
        ],
    },
}


relationships = [
    # points, label near start, label near end, relationship name
    ([(530, 385), (680, 385)], (548, 353, "1"), (618, 353, "0..N"), "gera"),
    ([(1370, 520), (1540, 520)], (1386, 488, "1"), (1474, 488, "0..N"), "processa"),
    ([(1025, 865), (1025, 940), (1760, 940), (1760, 1050)], (1042, 878, "1"), (1679, 1005, "0..N"), "registra"),
    ([(2180, 865), (2180, 1050)], (2197, 880, "1"), (2197, 1007, "0..N"), "detalha"),
    ([(1760, 865), (1760, 965), (1140, 965), (1140, 1050)], (1777, 880, "1"), (1157, 1007, "0..N"), "participa"),
    ([(680, 1210), (820, 1210)], (698, 1178, "1"), (755, 1178, "1..N"), "contém"),
    ([(375, 1510), (375, 1670)], (392, 1525, "1"), (392, 1628, "1..N"), "divide-se"),
]


def draw_label_png(draw, x, y, value):
    bbox = draw.textbbox((0, 0), value, font=LABEL_FONT)
    w = bbox[2] - bbox[0] + 16
    h = bbox[3] - bbox[1] + 10
    draw.rounded_rectangle((x - 6, y - 4, x - 6 + w, y - 4 + h), radius=7, fill=WHITE, outline=LINE, width=1)
    draw.text((x + 2, y), value, fill=NAVY, font=LABEL_FONT)


def draw_png():
    image = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(image)
    draw.text((70, 62), "DER — Automação Accenture C6", fill=NAVY, font=TITLE_FONT)
    draw.text(
        (72, 130),
        "Modelo lógico acadêmico fiel ao núcleo de execução, auditoria e importação no CRM",
        fill=MUTED,
        font=SUBTITLE_FONT,
    )
    draw.rounded_rectangle((70, 183, 2330, 187), radius=2, fill=CYAN)

    for points, start_label, end_label, _ in relationships:
        draw.line(points, fill=LINE, width=5, joint="curve")
        draw.ellipse((points[0][0] - 5, points[0][1] - 5, points[0][0] + 5, points[0][1] + 5), fill=BLUE)
        draw.ellipse((points[-1][0] - 5, points[-1][1] - 5, points[-1][0] + 5, points[-1][1] + 5), fill=BLUE)
        draw_label_png(draw, *start_label)
        draw_label_png(draw, *end_label)

    for name, data in entities.items():
        x1, y1, x2, y2 = data["box"]
        draw.rounded_rectangle((x1 + 10, y1 + 12, x2 + 10, y2 + 12), radius=18, fill=SHADOW)
        draw.rounded_rectangle((x1, y1, x2, y2), radius=18, fill=WHITE, outline=BLUE, width=3)
        draw.rounded_rectangle((x1, y1, x2, y1 + 62), radius=18, fill=NAVY)
        draw.rectangle((x1, y1 + 44, x2, y1 + 62), fill=NAVY)
        draw.text((x1 + 22, y1 + 16), name, fill=WHITE, font=ENTITY_FONT)
        row_y = y1 + 70
        row_h = (y2 - row_y - 10) / len(data["attrs"])
        for idx, (key, attr, dtype) in enumerate(data["attrs"]):
            top = row_y + idx * row_h
            if idx % 2 == 1:
                draw.rectangle((x1 + 3, top, x2 - 3, top + row_h), fill=ROW)
            if key:
                draw.text((x1 + 16, top + 7), key, fill=CYAN if key in {"PK", "FK"} else BLUE, font=ATTR_BOLD_FONT)
            attr_x = x1 + 62
            draw.text((attr_x, top + 7), attr, fill=INK, font=ATTR_FONT)
            if dtype:
                dtype_bbox = draw.textbbox((0, 0), dtype, font=ATTR_FONT)
                dtype_x = x2 - 16 - (dtype_bbox[2] - dtype_bbox[0])
                draw.text((dtype_x, top + 7), dtype, fill=MUTED, font=ATTR_FONT)

    draw.rounded_rectangle((840, 1680, 2330, 2110), radius=18, fill=WHITE, outline=LINE, width=2)
    draw.text((875, 1714), "LEGENDA E DECISÕES DO MODELO", fill=NAVY, font=ENTITY_FONT)
    notes = [
        "PK = chave primária   •   FK = chave estrangeira   •   UQ = restrição de unicidade",
        "/ = atributo derivado   •   NULL = atributo opcional",
        "qtd_workers é calculada a partir dos workers vinculados à execução; não é uma entidade.",
        "CONTRATO_LOTE_IMPORTACAO resolve a relação N:N entre contratos e lotes de CRM.",
        "EVENTO_EXECUCAO registra a trilha temporal da execução e pode apontar para um contrato.",
        "Os totais persistidos em EXECUCAO e LOTE_IMPORTACAO funcionam como métricas-resumo.",
    ]
    y = 1770
    for note in notes:
        draw.ellipse((876, y + 7, 884, y + 15), fill=CYAN)
        draw.text((900, y), note, fill=INK, font=NOTE_FONT)
        y += 50

    image.save(OUT_DIR / "DER_ACCENTURE_C6.png", quality=96)


def svg_text(x, y, value, size, color, weight="normal", anchor="start"):
    return (
        f'<text x="{x}" y="{y}" font-family="Arial, sans-serif" font-size="{size}" '
        f'font-weight="{weight}" fill="{color}" text-anchor="{anchor}">{escape(value)}</text>'
    )


def draw_svg():
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{WIDTH}" height="{HEIGHT}" viewBox="0 0 {WIDTH} {HEIGHT}">',
        f'<rect width="{WIDTH}" height="{HEIGHT}" fill="{BG}"/>',
        '<defs><filter id="shadow" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="8" dy="10" stdDeviation="6" flood-color="#9BAFC3" flood-opacity="0.38"/></filter></defs>',
        svg_text(70, 105, "DER — Automação Accenture C6", 48, NAVY, "bold"),
        svg_text(72, 157, "Modelo lógico acadêmico fiel ao núcleo de execução, auditoria e importação no CRM", 24, MUTED),
        f'<rect x="70" y="183" width="2260" height="4" rx="2" fill="{CYAN}"/>',
    ]

    for points, start_label, end_label, _ in relationships:
        point_text = " ".join(f"{x},{y}" for x, y in points)
        out.append(f'<polyline points="{point_text}" fill="none" stroke="{LINE}" stroke-width="5" stroke-linejoin="round"/>')
        for x, y in (points[0], points[-1]):
            out.append(f'<circle cx="{x}" cy="{y}" r="5" fill="{BLUE}"/>')
        for x, y, label in (start_label, end_label):
            box_w = 54 if len(label) > 1 else 34
            out.append(f'<rect x="{x - 7}" y="{y - 22}" width="{box_w}" height="31" rx="7" fill="{WHITE}" stroke="{LINE}"/>')
            out.append(svg_text(x + 1, y + 1, label, 18, NAVY, "bold"))

    for name, data in entities.items():
        x1, y1, x2, y2 = data["box"]
        w, h = x2 - x1, y2 - y1
        out.append(f'<rect x="{x1}" y="{y1}" width="{w}" height="{h}" rx="18" fill="{WHITE}" stroke="{BLUE}" stroke-width="3" filter="url(#shadow)"/>')
        out.append(f'<path d="M{x1 + 18},{y1} H{x2 - 18} Q{x2},{y1} {x2},{y1 + 18} V{y1 + 62} H{x1} V{y1 + 18} Q{x1},{y1} {x1 + 18},{y1} Z" fill="{NAVY}"/>')
        out.append(svg_text(x1 + 22, y1 + 42, name, 27, WHITE, "bold"))
        row_y = y1 + 70
        row_h = (y2 - row_y - 10) / len(data["attrs"])
        for idx, (key, attr, dtype) in enumerate(data["attrs"]):
            top = row_y + idx * row_h
            if idx % 2 == 1:
                out.append(f'<rect x="{x1 + 3}" y="{top:.1f}" width="{w - 6}" height="{row_h:.1f}" fill="{ROW}"/>')
            if key:
                key_color = CYAN if key in {"PK", "FK"} else BLUE
                out.append(svg_text(x1 + 16, top + 25, key, 19, key_color, "bold"))
            out.append(svg_text(x1 + 62, top + 25, attr, 19, INK))
            if dtype:
                out.append(svg_text(x2 - 16, top + 25, dtype, 19, MUTED, anchor="end"))

    out.append(f'<rect x="840" y="1680" width="1490" height="430" rx="18" fill="{WHITE}" stroke="{LINE}" stroke-width="2"/>')
    out.append(svg_text(875, 1750, "LEGENDA E DECISÕES DO MODELO", 27, NAVY, "bold"))
    notes = [
        "PK = chave primária   •   FK = chave estrangeira   •   UQ = restrição de unicidade",
        "/ = atributo derivado   •   NULL = atributo opcional",
        "qtd_workers é calculada a partir dos workers vinculados à execução; não é uma entidade.",
        "CONTRATO_LOTE_IMPORTACAO resolve a relação N:N entre contratos e lotes de CRM.",
        "EVENTO_EXECUCAO registra a trilha temporal da execução e pode apontar para um contrato.",
        "Os totais persistidos em EXECUCAO e LOTE_IMPORTACAO funcionam como métricas-resumo.",
    ]
    y = 1800
    for note in notes:
        out.append(f'<circle cx="880" cy="{y - 6}" r="4" fill="{CYAN}"/>')
        out.append(svg_text(900, y, note, 18, INK))
        y += 50
    out.append("</svg>")
    (OUT_DIR / "DER_ACCENTURE_C6.svg").write_text("\n".join(out), encoding="utf-8")


if __name__ == "__main__":
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    draw_png()
    draw_svg()
    print(OUT_DIR / "DER_ACCENTURE_C6.png")
    print(OUT_DIR / "DER_ACCENTURE_C6.svg")
