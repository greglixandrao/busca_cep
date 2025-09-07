import os
from dotenv import load_dotenv

# Carregar variáveis do arquivo .env
load_dotenv()

class Settings:
    """Configurações da aplicação"""
    
    # Configurações da aplicação
    APP_NAME: str = os.getenv("APP_NAME", "API de Busca de CEP")
    APP_VERSION: str = os.getenv("APP_VERSION", "1.0.0")
    DEBUG: bool = os.getenv("DEBUG", "False").lower() == "true"
    
    # Configurações do servidor
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", 8000))
    
    # Configurações da API ViaCEP
    VIACEP_BASE_URL: str = os.getenv("VIACEP_BASE_URL", "https://viacep.com.br/ws")
    VIACEP_TIMEOUT: int = int(os.getenv("VIACEP_TIMEOUT", 10))

# Instância das configurações
settings = Settings()
