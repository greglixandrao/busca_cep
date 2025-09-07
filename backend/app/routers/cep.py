from fastapi import APIRouter, HTTPException, Path
from app.models.cep import CEPResponse, ErrorResponse
from app.services.viacep_service import ViaCEPService
import httpx

router = APIRouter(prefix="/api/v1", tags=["CEP"])


@router.get(
    "/cep/{cep}",
    response_model=CEPResponse,
    responses={
        404: {"model": ErrorResponse, "description": "CEP não encontrado"},
        400: {"model": ErrorResponse, "description": "CEP inválido"},
        500: {"model": ErrorResponse, "description": "Erro interno do servidor"}
    },
    summary="Buscar endereço por CEP",
    description="Busca informações de endereço através do CEP utilizando a API do ViaCEP"
)
async def get_cep(
    cep: str = Path(..., description="CEP no formato 12345678 ou 12345-678", min_length=8, max_length=9)
):
    """
    Busca endereço pelo CEP
    
    - **cep**: CEP a ser consultado (formato: 12345678 ou 12345-678)
    
    Retorna as informações do endereço encontrado ou erro se não encontrado.
    """
    try:
        async with ViaCEPService() as service:
            address = await service.get_address_by_cep(cep)
            
            if address is None:
                raise HTTPException(
                    status_code=404,
                    detail="CEP não encontrado"
                )
            
            return address
            
    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )
    except httpx.HTTPError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao consultar serviço externo: {str(e)}"
        )
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail="Erro interno do servidor"
        )


@router.get(
    "/health",
    summary="Health Check",
    description="Verifica se a API está funcionando"
)
async def health_check():
    """Endpoint para verificação de saúde da API"""
    return {"status": "ok", "message": "API de busca de CEP funcionando"}
