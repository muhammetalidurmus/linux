#!/bin/bash

# Ubuntu Docker Kurulum ve Sistem Yapılandırma Script'i
# Bu script yeni bir Ubuntu makinesinde Docker kurulumu yapar ve temel güvenlik yapılandırması gerçekleştirir

set -e  # Hata durumunda script'i durdur

echo "🚀 Ubuntu Docker Kurulum ve Yapılandırma Script'i başlatılıyor..."
echo "=================================================="

# Root kontrolü
if [[ $EUID -eq 0 ]]; then
   echo "❌ Bu script'i root kullanıcısı ile çalıştırmayın. sudo ile çalıştırın."
   exit 1
fi

# Sistem güncellemesi
echo "📦 Sistem paketleri güncelleniyor..."
sudo apt update && sudo apt upgrade -y

# Gerekli paketlerin kurulumu
echo "🔧 Gerekli paketler kuruluyor..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Docker'ın eski sürümlerini kaldır
echo "🧹 Eski Docker sürümleri temizleniyor..."
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Docker GPG anahtarını ekle
echo "🔐 Docker GPG anahtarı ekleniyor..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker deposunu ekle
echo "📋 Docker deposu ekleniyor..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paket listesini güncelle
echo "🔄 Paket listesi güncelleniyor..."
sudo apt update

# Docker Engine'i kur
echo "🐳 Docker Engine kuruluyor..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker servisini başlat ve otomatik başlatmayı etkinleştir
echo "⚡ Docker servisi başlatılıyor..."
sudo systemctl start docker
sudo systemctl enable docker

# Kullanıcıyı docker grubuna ekle
echo "👤 Kullanıcı docker grubuna ekleniyor..."
sudo usermod -aG docker $USER

# UFW güvenlik duvarını kur ve etkinleştir
echo "🛡️ UFW güvenlik duvarı yapılandırılıyor..."
sudo apt install -y ufw

# UFW varsayılan kuralları ayarla
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH portunu aç (mevcut bağlantının kopmamması için)
echo "🔓 SSH portu (22) açılıyor..."
sudo ufw allow ssh

# HTTP ve HTTPS portlarını aç
echo "🌐 HTTP (80) ve HTTPS (443) portları açılıyor..."
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# UFW'yi etkinleştir
echo "✅ UFW etkinleştiriliyor..."
sudo ufw --force enable

# Docker Compose kurulumu (standalone sürüm)
echo "🏗️ Docker Compose standalone sürümü kuruluyor..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Node.js 22.x LTS kurulumu (Claude Code için)
echo "📦 Node.js 22.x LTS kuruluyor..."
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs

# npm'i en son sürüme güncelle
echo "🔄 npm güncelleniyor..."
sudo npm install -g npm@latest

# Claude Code kurulumu
echo "🤖 Claude Code kuruluyor..."
sudo npm install -g @anthropic-ai/claude-code

# Claude Code için gerekli olan ek paketler
echo "📋 Claude Code için ek paketler kuruluyor..."
sudo apt install -y git build-essential

# Kurulum kontrolü
echo "🔍 Kurulum kontrol ediliyor..."
echo "Docker sürümü:"
docker --version

echo "Docker Compose sürümü:"
docker-compose --version

echo "Node.js sürümü:"
node --version

echo "npm sürümü:"
npm --version

echo "Claude Code sürümü:"
claude --version

echo "UFW durumu:"
sudo ufw status

echo "=================================================="
echo "✅ Kurulum tamamlandı!"
echo ""
echo "📝 Önemli notlar:"
echo "• Docker kullanabilmek için oturumu kapatıp tekrar açmanız gerekebilir"
echo "• Veya 'newgrp docker' komutunu çalıştırabilirsiniz"
echo "• UFW güvenlik duvarı etkinleştirildi"
echo "• Açık portlar: 22 (SSH), 80 (HTTP), 443 (HTTPS)"
echo "• Node.js 22.x LTS kuruldu"
echo "• Claude Code kuruldu - API key'inizi ayarlamayı unutmayın"
echo ""
echo "🔑 Claude Code kurulumu:"
echo "• API key ayarlamak için: claude auth"
echo "• Veya environment variable: export ANTHROPIC_API_KEY=your_key_here"
echo ""
echo "🧪 Test komutları:"
echo "• Docker: docker run hello-world"
echo "• Node.js: node --version"
echo "• Claude Code: claude --help"
echo "=================================================="
