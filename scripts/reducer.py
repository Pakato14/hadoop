#!/usr/bin/env python3
# reducer.py

import sys

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
        if produto.strip() == "DIESEL":
            preco = preco.replace(",", ".")
            soma += float(preco)
            contador += 1
    except Exception as e:
        print(f"ERRO: {str(e)} na linha: {linha}", file=sys.stderr)
        continue

if contador > 0:
    media = soma / contador
    print(f"Preço médio do DIESEL em SP: {media:.2f}")
else:
    print("Nenhum dado válido encontrado para DIESEL em SP.")
