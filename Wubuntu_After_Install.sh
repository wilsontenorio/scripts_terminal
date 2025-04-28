#!/bin/bash
#Arquivo de instalação automática para programas normalmente usados no Windows Ubuntu.

# Efetua a atualização dos pacotes já existentes na máquina.
echo "Executando Atualizacao dos pacotes atualmente instalados."
sudo apt update && sudo apt upgrade -y
sudo apt update -y

# Efetua adição do repositório de drivers de vídeo NVidea
echo "Executando adicao do pacote de drivers Nvidea."
sudo add-apt-repository ppa:kelebek333/nvidia-legacy
sudo apt update -y

# Remoção dos pacotes powershell , Wine e Onedrive, desnecessários
echo "Removendo pacotes Powershell, Wine e Onedrive."
sudo apt purge powershell wine-stable winetricks onedrive -y
sudo apt autoremove -y
sudo apt update

# Verifica se o sistema já possui o "Curl" instalado
if ! command -v curl &> /dev/null; then
    sudo apt install -y curl
fi

# Efetua verificação do Teamviewer mais recente e após isto efetua instalação do mesmo.
echo "Verificando a versão mais recente do TeamViewer..."
TV_URL="https://www.teamviewer.com/pt-br/download/linux/"
TV_VERSION=$(curl -s "$TV_URL" | grep -oP 'Versão\s+\K\d+\.\d+\.\d+' | head -n 1)

if [ -z "$TV_VERSION" ]; then
    echo "Não foi possível obter a versão. Usando URL genérica..."
    DEB_URL="https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
else
    echo "Versão encontrada: $TV_VERSION"
    DEB_URL="https://download.teamviewer.com/download/linux/teamviewer_${TV_VERSION}_amd64.deb"
fi

# Download e instalação
echo "Baixando TeamViewer..."
wget -O teamviewer.deb "$DEB_URL" || {
    echo "Falha no download, tentando URL alternativa..."
    wget -O teamviewer.deb "https://download.teamviewer.com/download/linux/teamviewer_amd64.deb"
}

sudo apt install -y ./teamviewer.deb
rm teamviewer.deb
echo "TeamViewer instalado com sucesso!"

# Efetuando configuração do Teamviewer
# Aceitando licença do teamviewer
sudo teamviewer licence accept
# Habilitando respositorio estável do teamviewer
sudo teamviewer repo stable
# Habilitando o Teamviewer na inicialização do sistema
sudo teamviewer daemon enable
sudo teamviewer daemon start

# Adiciona chave GPG do Anydesk
sudo apt update
sudo apt install -y ca-certificates curl apt-transport-https
echo "Adicionando chaves GPG do Anydesk"
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
sudo chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc

# Adiciona o repositorio Anydesk
echo "Adicionando repositorio Anydesk"
echo "deb [signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] https://deb.anydesk.com all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null

# Update apt caches and install the AnyDesk client
sudo apt update
echo "Instalando Anydesk"
sudo apt install -y anydesk

# Instalação do Unzip
sudo apt install -y unzip

# Instalação do Antivirus:
echo "Instalando antivirus ClamAV"
sudo apt install -y clamav clamtk clamav-daemon

# Instalação do conjunto de "pacotes essenciais" para o chrome
echo "Efetuando instalacao de pacotes essenciais para instalação do Google Chrome"
sudo apt install -y curl apt-transport-https gdebi
# Download do Chrome Stable
echo "Efetuando Download do Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

# Instalação do chrome e após a instalação, a remoção do arquivo
echo "Efetuando Instalação do Google Chrome"
sudo apt install google-chrome* -y
echo "Removendo instalador"
rm google-chrome-stable_current_amd64.deb

# Instalação do Firefox
echo "Instalando Firefox"
sudo apt install -y firefox

# Instalação do GLPI
read -p "Deseja rodar o GLPI agora? (s/n) " setupglpi
    if [[ "$setupglpi" =~ ^[sSyY] ]]; then
        # verifica a ultima versão do GPLI
        REPOGLPI="glpi-project/glpi-agent"
        LATEST_VERSION=$(curl -s https://api.github.com/repos/$REPOGLPI/releases/latest | grep -oP '"tag_name": "\K[^"]+')
        echo "Localizada versão $LATEST_VERSION..."
        PL_URL="https://github.com/$REPOGLPI/releases/download/$LATEST_VERSION/glpi-agent-${LATEST_VERSION}-linux-installer.pl"
        wget -O glpi-agent.pl "$PL_URL"
        read -p "Digite a URL do agente GLPI:" GLPI_URL
        sudo perl glpi-agent.pl -s $GLPI_URL
        echo "GLPI_$LATEST_VERSION Instalado com sucesso..."
        rm glpi-agent.pl

        read -p "Deseja rodar o GLPI agora? (s/n) " rodarglpi
            if [[ "$rodarglpi" =~ ^[sSyY] ]]; then
                sudo  glpi-agent
            else
                echo "pulando processo de atualização"
            fi
    else
        echo "Pulando instalação do GLPI."
    fi

# Pergunta se deseja instalar o Holyrics
read -p "Deseja baixar e instalar o Holyrics? (s/n) " holyrics
if [[ "$holyrics" =~ ^[sSyY] ]]; then
    curl -L https://www.holyrics.com.br/download/app/download-setup-linux.php --output holyrics.zip
    unzip holyrics.zip
    sudo chmod +x *olyrics*.run
    sudo ./*olyrics*.run -y
else
    echo "Pulando instalação do Holyrics"
fi


# Pergunta se deseja instalar o módulo xorg-modulepath
echo "Utilize o xorg-modulepath-fix somente se tiver problemas de resolução de tela"
read -p "Deseja instalar o xorg-modulepath-fix? (s/n) " resposta
if [[ "$resposta" =~ ^[sSyY] ]]; then
    # Instalaçao do Xorg Fix para não ter problemas de resoluções de tela ao usar saída VGA:
    echo "Instalando módulo Xorg Fix para resolver problemas de resoluções na saida VGA"
    sudo apt install -y xorg-modulepath-fix
else
    echo "Pulando instalação do xorg-modulepath-fix."
fi

# Pergunta se é necessário adicionar um novo usuário ou não
while true; do
    read -p "Deseja adicionar um novo usuário? (s/n) " newuser
        case "$newuser" in
        [sSyY]* )
            read -p "Digite o Nome Completo: " fullname
            read -p "Digite o username desejado: " username
            read -p "Digite a senha desejada: " userpass

            sudo useradd -m -s "/bin/bash" -c "$fullname" "$username"

            echo "$username:$userpass" | sudo chpasswd
            echo -e "\nUsuário $NOME_USUARIO criado com sucesso!"

            read -p "Deseja tornar o usuario administrador? (sudo)" sudo
                if [[ "$sudo" =~ ^[sSyY] ]]; then
                    sudo usermod -aG sudo $username
                else
                    echo "Usuario sem poderes de elevacao."
                fi
                break
                ;;
        [nN]* )
            echo "Pulando criacao de contas."
           break
           ;;
        * )
        echo "Por Favor, escolher s (sim) ou n (não)."
        ;;
        esac
done
