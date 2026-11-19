#!/usr/bin/env bash
set -euo pipefail

NOME="$1"
RAM="$2"
DISCO_MB="$3"
PORTA_SSH="$4"
PORTA_APP="$5"
SEED="$6"

BASE="$HOME/avaliacao/iac/imagens/ubuntu-24.04-base.vdi"
DIR="$HOME/avaliacao/iac/maquinas/$NOME"
VDI="$DIR/disco.vdi"

if VBoxManage list vms | grep -Fq "\"$NOME\""; then
    echo "ERRO: VM $NOME ja existe. Nada foi alterado."
    exit 1
fi

if [ -e "$DIR" ]; then
    echo "ERRO: Diretorio $DIR ja existe."
    exit 1
fi

mkdir -p "$DIR"

echo "=== CLONANDO DISCO: $NOME ==="
VBoxManage clonemedium disk "$BASE" "$VDI" --format VDI

echo "=== EXPANDINDO DISCO ==="
VBoxManage modifymedium disk "$VDI" --resize "$DISCO_MB"

echo "=== CRIANDO VM ==="
VBoxManage createvm \
    --name "$NOME" \
    --ostype Ubuntu_64 \
    --basefolder "$DIR" \
    --register

VBoxManage modifyvm "$NOME" \
    --memory "$RAM" \
    --cpus 2 \
    --firmware bios \
    --graphicscontroller vmsvga \
    --nic1 nat \
    --boot1 disk \
    --boot2 dvd \
    --boot3 none \
    --boot4 none

VBoxManage modifyvm "$NOME" \
    --natpf1 "ssh,tcp,127.0.0.1,$PORTA_SSH,,22"

PORTA_INTERNA="$PORTA_APP"

if [ "$NOME" = "avaliacao-vm1-web" ]; then
    PORTA_INTERNA=8080
fi

VBoxManage modifyvm "$NOME" \
    --natpf1 "app,tcp,127.0.0.1,$PORTA_APP,,$PORTA_INTERNA"

VBoxManage storagectl "$NOME" \
    --name "SATA" \
    --add sata \
    --controller IntelAhci

VBoxManage storageattach "$NOME" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "$VDI"

VBoxManage storageattach "$NOME" \
    --storagectl "SATA" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium "$SEED"

echo "=== VM $NOME CRIADA ==="
