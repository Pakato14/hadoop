#!/usr/bin/env python3
import sys
import csv

reader = csv.reader(sys.stdin, delimiter=';')
for row in reader:
    try:
        if row[0].strip() == "Regiao - Sigla" or row[1].strip() != "SP":
            continue
        produto = row[10].strip().upper()
        if "DIESEL" in produto:
            preco = row[12].replace(",", ".").strip()
            if preco:
                print(f"{produto}\t{preco}")
    except Exception:
        continue
