CREATE DATABASE CampeonatoFutebol;
GO

USE CampeonatoFutebol;
GO

CREATE TABLE Time(
    nome varchar(50) NOT NULL,
    apelido varchar(50) NOT NULL,
    data_criacao date NOT NULL,
    pontos int,
    vitorias int,
    gols_marcados int,
    gols_sofridos int,
    saldo_gols int,
    CONSTRAINT PK_Time PRIMARY KEY (nome),
);
GO

CREATE TABLE Jogo(
    rodada int NOT NULL,
    time_mandante varchar(50) NOT NULL,
    time_visitante varchar(50) NOT NULL,
    gols_mandante int,
    gols_visitante int,
    total_gols int,
    CONSTRAINT PK_Jogo PRIMARY KEY (rodada, time_mandante, time_visitante),
    CONSTRAINT FK_TimeMandante FOREIGN KEY (time_mandante) REFERENCES Time (nome),
    CONSTRAINT FK_TimeVisitante FOREIGN KEY (time_visitante) REFERENCES Time (nome),
);
GO


