#!/usr/bin/env python3
# mapper.py

import sys
import csv

for linha in sys.stdin:
    try:
        linha = linha.strip()
        if not linha:
            continue

        # Força leitura como CSV com ; e ignora erros
        reader = csv.reader([linha], delimiter=';')
        cols = next(reader)

        if len(cols) < 14:
            continue

        estado = cols[1].strip()
        produto = cols[10].strip().upper()
        preco = cols[12].replace(',', '.').strip()

        if estado == "SP" and produto.startswith("DIESEL") and preco:
            print(f"{produto}\t{preco}")

    except Exception as e:
        print(f"ERRO: {str(e)} na linha: {linha}", file=sys.stderr)
