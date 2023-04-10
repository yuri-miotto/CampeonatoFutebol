USE CampeonatoFutebol;
GO

--Procedure para cadastrar um time:
CREATE OR ALTER PROCEDURE CadastrarTime @nome varchar(50), @apelido varchar(50)
AS
BEGIN
    DECLARE @nome_time varchar(50)

    SELECT @nome_time=nome FROM [Time] WHERE nome=@nome
    IF(@nome_time is null)
        BEGIN
        INSERT INTO [Time] VALUES (@nome, @apelido, GETDATE(), 0, 0, 0, 0, 0)
        PRINT('Time cadastrado com sucesso!')
        END
    ELSE
        PRINT('Este Time já existe!!!')

END;
GO

EXEC.CadastrarTime SaoPaulo, Tricolor
EXEC.CadastrarTime Corinthians, Timao
EXEC.CadastrarTime Palmeiras, Porco
EXEC.CadastrarTime Santos, Peixe
EXEC.CadastrarTime Ferroviaria, Locomotiva

select * FROM [Time]

GO

--Procedure que inclui um jogo e já calcula os pontos:
CREATE OR ALTER PROCEDURE IncluirJogo @rodada int, @time_mandante varchar(50), @time_visitante varchar(50), @gols_mandante int, @gols_visitante int
AS
BEGIN
    DECLARE @N_RODADA int, @MANDANTE varchar(50), @VISITANTE varchar(50)

    SELECT @N_RODADA=rodada, @MANDANTE=time_mandante, @VISITANTE=time_visitante FROM Jogo WHERE rodada=@rodada and time_mandante=@time_mandante and time_visitante=@time_visitante
        
    IF(@N_RODADA is null and @MANDANTE is null and @VISITANTE is null)
    BEGIN
        BEGIN
            INSERT INTO [Jogo] VALUES (@rodada, @time_mandante, @time_visitante, @gols_mandante, @gols_visitante, @gols_mandante+@gols_visitante)
            PRINT('Jogo cadastrado com sucesso!')
        END
        
        BEGIN
            IF(@gols_mandante > @gols_visitante) 
                BEGIN
                    UPDATE [Time] SET pontos=pontos+3 WHERE nome=@time_mandante
                    UPDATE [Time] SET vitorias=vitorias+1 WHERE nome=@time_mandante
                END

            IF(@gols_mandante < @gols_visitante) 
                BEGIN
                    UPDATE [Time] SET pontos=pontos+5 WHERE nome=@time_visitante
                    UPDATE [Time] SET vitorias=vitorias+1 WHERE nome=@time_visitante
                END

            ELSE
                BEGIN
                    UPDATE [Time] SET pontos=pontos+1 WHERE nome=@time_visitante AND nome=@time_mandante
                END
        END

        BEGIN
            UPDATE [Time] SET gols_marcados=gols_marcados+@gols_mandante WHERE nome=@time_mandante
            UPDATE [Time] SET gols_marcados=gols_marcados+@gols_visitante WHERE nome=@time_visitante
            UPDATE [Time] SET gols_sofridos=gols_sofridos+@gols_visitante WHERE nome=@time_mandante
            UPDATE [Time] SET gols_sofridos=gols_sofridos+@gols_mandante WHERE nome=@time_visitante
        END

        BEGIN
            UPDATE [Time] SET saldo_gols=gols_marcados-gols_sofridos
        END
    END
        
    ELSE
        PRINT('Este Jogo já foi cadastrado!!!')

END;
GO

EXEC.IncluirJogo 1, SaoPaulo, Corinthians, 5, 2
EXEC.IncluirJogo 1, SaoPaulo, Palmeiras, 3, 1
EXEC.IncluirJogo 1, SaoPaulo, Santos, 2, 2
EXEC.IncluirJogo 1, SaoPaulo, Ferroviaria, 0, 0
EXEC.IncluirJogo 1, Corinthians, Palmeiras, 2, 1
EXEC.IncluirJogo 1, Corinthians, Santos, 0, 1
EXEC.IncluirJogo 1, Corinthians, Ferroviaria, 3, 1
EXEC.IncluirJogo 1, Palmeiras, Santos, 4, 2
EXEC.IncluirJogo 1, Palmeiras, Ferroviaria, 0, 0
EXEC.IncluirJogo 1, Santos, Ferroviaria, 1, 2

EXEC.IncluirJogo 2, Ferroviaria, SaoPaulo, 3, 0
EXEC.IncluirJogo 2, Ferroviaria, Corinthians, 5, 2
EXEC.IncluirJogo 2, Ferroviaria, Palmeiras, 3, 5
EXEC.IncluirJogo 2, Ferroviaria, Santos, 4, 2
EXEC.IncluirJogo 2, Santos, SaoPaulo, 0, 2
EXEC.IncluirJogo 2, Santos, Corinthians, 5, 2
EXEC.IncluirJogo 2, Santos, Palmeiras, 0, 0
EXEC.IncluirJogo 2, Palmeiras, Corinthians, 3, 1
EXEC.IncluirJogo 2, Palmeiras, SaoPaulo, 0, 2
EXEC.IncluirJogo 2, Corinthians, SaoPaulo, 0, 2


GO

--Procedure para verificar a Classificação:
CREATE OR ALTER PROCEDURE VerificaCLassificacao
AS
BEGIN
    SELECT * FROM [Time] ORDER BY pontos DESC, vitorias DESC, saldo_gols DESC
END;
GO


--Procedure para verificar o Campeao:
CREATE OR ALTER PROCEDURE VerificaCampeao
AS
BEGIN
    SELECT TOP(1) * FROM [Time] ORDER BY pontos DESC, vitorias DESC, saldo_gols DESC 
END;
GO


--Procedure para verificar o Time que fez mais gols:
CREATE OR ALTER PROCEDURE FezMaisGols
AS
BEGIN
    SELECT TOP(1) * FROM [Time] ORDER BY gols_marcados DESC
END;
GO


--Procedure para verificar o Time que sofreu mais gols:
CREATE OR ALTER PROCEDURE SofreuMaisGols
AS
BEGIN
    SELECT TOP(1) * FROM [Time] ORDER BY gols_sofridos DESC
END;
GO



--Procedure para verificar o Jogo que teve mais gols:
CREATE OR ALTER PROCEDURE JogoComMaisGols
AS
BEGIN
    SELECT TOP(1) * FROM Jogo ORDER BY total_gols DESC
END;
GO


select * FROM [Time]

select * FROM Jogo

GO

--Trigger para calcular pontuação após cada jogo:
CREATE OR ALTER TRIGGER CalculaPontuacao ON [Time] AFTER INSERT
AS
BEGIN
    DECLARE @rodada int, @time_mandante varchar(50), @time_visitante varchar(50), @gols_mandante int, @gols_visitante int
    BEGIN
            IF(@gols_mandante > @gols_visitante) 
                BEGIN
                    UPDATE [Time] SET pontos=pontos+3 WHERE nome=@time_mandante
                    UPDATE [Time] SET vitorias=vitorias+1 WHERE nome=@time_mandante
                END

            IF(@gols_mandante < @gols_visitante) 
                BEGIN
                    UPDATE [Time] SET pontos=pontos+5 WHERE nome=@time_visitante
                    UPDATE [Time] SET vitorias=vitorias+1 WHERE nome=@time_visitante
                END

            ELSE
                BEGIN
                    UPDATE [Time] SET pontos=pontos+1 WHERE nome=@time_visitante AND nome=@time_mandante
                END
        END

END;
GO


