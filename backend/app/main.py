from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import cep

# Criar instância do FastAPI
app = FastAPI(
    title="API de Busca de CEP",
    description="API para busca de endereços brasileiros através do CEP utilizando a API do ViaCEP",
    version="1.0.0",
    contact={
        "name": "Greg Lixandrão",
        "email": "contato@greglixandrao.com",
    },
    license_info={
        "name": "MIT",
    },
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Em produção, especificar domínios específicos
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(cep.router)

# Endpoint raiz
@app.get("/", tags=["Root"])
async def root():
    """Endpoint raiz da API"""
    return {
        "message": "API de Busca de CEP",
        "version": "1.0.0",
        "docs": "/docs",
        "redoc": "/redoc"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
