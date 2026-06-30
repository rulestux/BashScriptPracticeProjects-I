#!/usr/bin/env bash

#################################################################
# monitora-dou.sh - Rastreia atualizações no D.O.U. para um     #
# nome fornecido como parâmetro entre aspas duplas ou hardcoded #
# abaixo.                                                       #
#                                                               #
# Site:         https://github.com/rulestux                     #
# Author:       Jean Felipe                                     #
# Maintenance:  Jean Felipe                                     #
#                                                               #
# Usage:                                                        #
# ./monitora-dou.sh "Nome Completo de Candidato"                #
#                                                               #
#################################################################
# Dependencies: curl, html2text, notify-send, xfce4-terminal    #
# Optional Deps: zenity, xmessage                               #
#                                                               #
#################################################################
# History:                                                      #
#   v1.0 2026-06-29, Jean Felipe.                               #
#                                                               #
#################################################################
# Tested on:                                                    #
#   zsh v5.9 / bash v5.2                                        #
#                                                               #
#################################################################

# Acrescentar a linha abaixo ao arquivo `/etc/anacrontab`, para
# automatizar a execução do script diariamente (O horário de
# execução do anacron pode ser checado e ajustado no arquivo
# `/etc/crontab`):
# 1   5   dou.monitoramento   su - SEU_USUARIO -c "DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u SEU_USUARIO)/bus /caminho/para/monitora-dou.sh"

# Inserir o nome para a busca:
NAME_SEARCH="Nome Completo de Candidato"

# Testar se o nome foi passado como parâmetro (Se nenhum parâmetro
# for passado, ele assume o nome inserido hardcoded acima):
if [ ! -z "$1" ]; then
    NAME_SEARCH="$1"
fi

# Validação de Dependências Críticas (Atenção quando for alternar
# o método de notificação):
for cmd in curl html2text notify-send xfce4-terminal; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Erro: A ferramenta crítica '$cmd' não está instalada."
        exit 1
    fi
done

# Codifica o espaço como '%20' para a URL do curl com sed:
#NAME_URL=$(echo "$NAME_SEARCH" | sed 's/ /%20/g')

# Alternativamente, codifica o espaço como %20 no Bash (mais rápido que o sed):
NAME_URL="${NAME_SEARCH// /%20}"

URL="https://www.in.gov.br/consulta/-/buscar/dou?q=%22${NAME_URL}%22&s=todos&exactDate=all&sortType=0"

# Arquivos de referência na pasta pessoal do usuário para persistência:
DATA_DIR="$HOME/.dou_monitor"
mkdir -p "$DATA_DIR"
OLD_FILE="$DATA_DIR/old-file.txt"
NEW_FILE="$DATA_DIR/new-file.txt"

# Simulando um navegador real para evitar bloqueios no servidor do D.O.U.:
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

#################################################################

# I. Faz o download e extrai o texto bruto:
curl -s -A "$USER_AGENT" "$URL" | html2text > "$NEW_FILE"

# Se o download falhar ou cair em página de erro/bloqueio, aborta para evitar alarme falso:
if [ ! -s "$NEW_FILE" ] || ! grep -q -i "busca" "$NEW_FILE"; then
    echo "Erro: Falha de conexão, página vazia ou o site do D.O.U mudou o comportamento."
    exit 1
fi

# II. Se for a primeira execução da história, cria a referência e encerra:
if [ ! -f "$OLD_FILE" ]; then
    cp "$NEW_FILE" "$OLD_FILE"
    exit 0
fi

# III. Compara o resultado atual com o anterior:
if ! diff -q "$OLD_FILE" "$NEW_FILE" > /dev/null; then

    # Atualiza a referência para não notificar a mesma coisa no dia seguinte:
    cp "$NEW_FILE" "$OLD_FILE"

    # IV. LOOP DE NOTIFICAÇÃO PERSISTENTE
    while true; do

        # -----------------------------------------------------------------
        # MÉTODO I: notify-send + read via Terminal (Ativo por padrão)
        # -----------------------------------------------------------------
        # Dispara o balão persistente no sistema (critical não some sozinho no dunst):
        notify-send -u critical "ALERTA D.O.U." "Nova publicação encontrada para: $NAME_SEARCH\!"[cite: 4]

        # Abre o terminal como processo filho, aguardando o ENTER
        # (Se o terminal fechar com sucesso, ele retorna o status 0):
        xfce4-terminal --title="ALERTA D.O.U." -e "bash -c '
            echo -e \"\033[5;31;1m[ALERTA]\033[0m Nova publicação detectada para: $NAME_SEARCH\";
            read -p \"Pressione [ENTER] para confirmar a leitura e encerrar os alertas: \";
        '" 2>/dev/null

        # Verifica se o terminal fechou porque você deu ENTER (sucesso = 0)
        # (Se fechar a janela no X, o código gerado será diferente de 0 e o loop continua):
        if [ $? -eq 0 ]; then
            break
        fi
        # -----------------------------------------------------------------
        # MÉTODO II: notify-send Interativo Puro com dunst
        # -----------------------------------------------------------------
        #RESPONSE=$(notify-send -u critical \
        #    --action="ok=Confirmar Leitura" \
        #    "ALERTA D.O.U." \
        #    "Nova publicação encontrada para: $NAME_SEARCH\!")
        #
        #if [ "$RESPONSE" = "ok" ]; then
        #    break
        #fi

        # -----------------------------------------------------------------
        # MÉTODO III: zenity
        # -----------------------------------------------------------------
        #notify-send -u critical "ALERTA D.O.U." "Nova publicação encontrada para: $NAME_SEARCH\!"
        #zenity --info --title="Alerta de Publicação no D.O.U." --text="Uma nova publicação contendo '$NAME_SEARCH' foi detectada.\n\nClique em OK para confirmar a leitura e finalizar os alertas." --width=400
        #if [ $? -eq 0 ]; then
        #    break
        #fi

        # -----------------------------------------------------------------
        # MÉTODO IV: xmessage Universal (Descomente abaixo para usar)
        # -----------------------------------------------------------------
        #notify-send -u critical "ALERTA D.O.U." "Nova publicação encontrada para: $NAME_SEARCH\!"
        #xmessage -center -buttons "OK:0","Ignorar:1" "Uma nova publicação contendo '$NAME_SEARCH' foi detectada. Clique em OK para parar os alertas."
        #if [ $? -eq 0 ]; then
        #    break
        #fi

        # Se a notificação for ignorada ou fechada, espera 5 minutos e repete
        sleep 300
    done
fi
