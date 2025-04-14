#!/usr/bin/env python3
# reducer.py

import io
import sys

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

soma = 0.0
contador = 0

for linha in sys.stdin:
    try:
        linha = linha.strip()
        if not linha:
            continue

        partes = linha.split("\t")
        if len(partes) != 2:
            print(f"LINHA INVÁLIDA: {linha}", file=sys.stderr)
            continue

        produto, preco = partes
        produto = produto.strip()
        preco = preco.strip().replace(",", ".")

        if produto.upper() == "DIESEL":
            try:
                valor = float(preco)
                soma += valor
                contador += 1
            except ValueError:
                print(f"VALOR INVÁLIDO: '{preco}' na linha: {linha}", file=sys.stderr)
                continue

    except Exception as e:
        print(f"ERRO GERAL: {str(e)} na linha: {linha}", file=sys.stderr)
        continue

if contador > 0:
    media = soma / contador
    print(f"Preço médio do DIESEL em SP: {media:.2f}")
else:
    print("Nenhum dado válido encontrado para DIESEL em SP.")
