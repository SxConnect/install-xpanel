@echo off
REM ============================================
REM XPanel - Instalador Windows (Batch Wrapper)
REM ============================================

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║                    XPanel Installer v2.0                       ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Verificar se está executando como Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [X] Este instalador precisa ser executado como Administrador
    echo.
    echo Clique com botao direito neste arquivo e selecione:
    echo "Executar como Administrador"
    echo.
    pause
    exit /b 1
)

echo [i] Iniciando instalador PowerShell...
echo.

REM Executar o script PowerShell
powershell.exe -ExecutionPolicy Bypass -File "%~dp0install-windows.ps1"

if %errorLevel% neq 0 (
    echo.
    echo [X] Erro durante a instalacao
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] Instalacao concluida!
echo.
pause
