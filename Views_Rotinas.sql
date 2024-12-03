-- VIEW ESTOQUE DE EPI

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `estoque_epi` AS
    SELECT 
        `e`.`idEPI` AS `idEPI`,
        `e`.`nome_epi` AS `nome_epi`,
        `e`.`tipo_epi` AS `tipo_epi`,
        `e`.`quantidade_estoque` AS `quantidade_estoque`,
        `e`.`descricao_epi` AS `descricao_epi`
    FROM
        `epi` `e`
    ORDER BY `e`.`idEPI`;


-- VIEW HISTÓRICO DE ENTREGAS

DELIMITER //
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `historico_entregas` AS
    SELECT 
        `f`.`idFUNCIONARIO` AS `idFUNCIONARIO`,
        `f`.`nome_funcionario` AS `nome_funcionario`,
        `e`.`nome_epi` AS `nome_epi`,
        `e`.`idEPI` AS `idEPI`,
        `fe`.`data_e_hora` AS `data_e_hora`,
        `fe`.`situacao_entrega` AS `situacao_entrega`,
        `fe`.`quantidade_entregue` AS `quantidade_entregue`,
        `fe`.`descricao_entrega` AS `descricao_entrega`
    FROM
        ((`funcionario_epi` `fe`
        JOIN `funcionario` `f` ON (`fe`.`FUNCIONARIO_idFUNCIONARIO` = `f`.`idFUNCIONARIO`))
        JOIN `epi` `e` ON (`fe`.`EPI_idEPI` = `e`.`idEPI`))
    ORDER BY `fe`.`data_e_hora` DESC;//
DELIMITER ;

-- VIEW EPIS POR CARGO

DELIMITER //

CREATE VIEW epis_por_cargo AS
SELECT
    c.nome_cargo,
    e.nome_epi
FROM
    cargo c
JOIN
    cargo_atividade ca ON c.nome_cargo = ca.CARGO_nome_cargo
JOIN
    epi_atividade ea ON ca.ATIVIDADE_idATIVIDADE = ea.ATIVIDADE_idATIVIDADE
JOIN
    epi e ON ea.EPI_idEPI = e.idEPI
ORDER BY
    c.nome_cargo, e.nome_epi;

//
DELIMITER ;

-- PROCEDURE CADASTRAR EPI

DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `cadastrar_epi`(
    IN p_nome_epi VARCHAR(100),
    IN p_tipo_epi VARCHAR(50),
    IN p_quantidade_estoque INT,
    IN p_descricao_epi TEXT,
    IN p_id_marca INT,  -- Adicionando o parâmetro para o idMARCA
    IN p_validade_epi DATE -- Adicionando o parâmetro para a validade do EPI
)
BEGIN
    -- Inserir um novo EPI na tabela epi
    INSERT INTO epi (nome_epi, tipo_epi, quantidade_estoque, descricao_epi, MARCA_idMARCA, validade_epi)
    VALUES (p_nome_epi, p_tipo_epi, p_quantidade_estoque, p_descricao_epi, p_id_marca, p_validade_epi);

    -- Exibir a tabela epi atualizada
    SELECT * FROM epi;
END
//
DELIMITER ;

-- PROCEDURE ATUALIZAR EPI

DELIMITER //

CREATE PROCEDURE atualizar_epi(
    IN p_idEPI INT,
    IN p_nome_epi VARCHAR(100),
    IN p_tipo_epi VARCHAR(50),
    IN p_quantidade_estoque INT,
    IN p_descricao_epi TEXT,
    IN p_id_marca INT,  -- Adicionando o parâmetro para o idMARCA
    IN p_validade_epi DATE -- Adicionando o parâmetro para a validade do EPI
)
BEGIN
    DECLARE v_nome_epi VARCHAR(100);
    DECLARE v_tipo_epi VARCHAR(50);
    DECLARE v_quantidade_estoque INT;
    DECLARE v_descricao_epi TEXT;
    DECLARE v_id_marca INT;  -- Variável para armazenar o idMARCA atual
    DECLARE v_validade_epi DATE; -- Variável para armazenar a validade do EPI atual

    -- Obter os valores atuais do EPI
    SELECT nome_epi, tipo_epi, quantidade_estoque, descricao_epi, MARCA_idMARCA, validade_epi
    INTO v_nome_epi, v_tipo_epi, v_quantidade_estoque, v_descricao_epi, v_id_marca, v_validade_epi
    FROM epi
    WHERE idEPI = p_idEPI;

    -- Atualizar os valores com base nos parâmetros de entrada
    IF p_nome_epi IS NOT NULL THEN
        SET v_nome_epi = p_nome_epi;
    END IF;
    IF p_tipo_epi IS NOT NULL THEN
        SET v_tipo_epi = p_tipo_epi;
    END IF;
    IF p_quantidade_estoque IS NOT NULL THEN
        SET v_quantidade_estoque = p_quantidade_estoque;
    END IF;
    IF p_descricao_epi IS NOT NULL THEN
        SET v_descricao_epi = p_descricao_epi;
    END IF;
    IF p_id_marca IS NOT NULL THEN
        SET v_id_marca = p_id_marca;
    END IF;
    IF p_validade_epi IS NOT NULL THEN
        SET v_validade_epi = p_validade_epi;
    END IF;

    -- Atualizar o EPI na tabela epi com base no idEPI
    UPDATE epi
    SET 
        nome_epi = v_nome_epi,
        tipo_epi = v_tipo_epi,
        quantidade_estoque = v_quantidade_estoque,
        descricao_epi = v_descricao_epi,
        MARCA_idMARCA = v_id_marca,  
        validade_epi = v_validade_epi 
    WHERE idEPI = p_idEPI;

    -- Exibir a tabela epi atualizada
    SELECT * FROM epi;
END;
//

DELIMITER ;



-- PROCEDURE REGISTRAR ENTREGA DE EPI

DELIMITER //
CREATE PROCEDURE registrar_entrega_epi (
    IN p_idFUNCIONARIO INT,
    IN p_idEPI INT,
    IN p_quantidade_entregue INT,
    IN p_situacao_entrega VARCHAR(20),
    IN p_descricao_entrega VARCHAR(200)
)
BEGIN
    -- Verifica se a quantidade solicitada está disponível no estoque
    DECLARE v_quantidade_estoque INT;
    SELECT quantidade_estoque INTO v_quantidade_estoque
    FROM epi
    WHERE idEPI = p_idEPI;

    IF v_quantidade_estoque < p_quantidade_entregue THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade insuficiente no estoque';
    ELSE
        -- Registra a entrega do EPI com data e hora atual
        INSERT INTO funcionario_epi (FUNCIONARIO_idFUNCIONARIO, EPI_idEPI, situacao_entrega, quantidade_entregue, descricao_entrega, data_e_hora)
        VALUES (p_idFUNCIONARIO, p_idEPI, p_situacao_entrega, p_quantidade_entregue, p_descricao_entrega, NOW()); -- ou CURRENT_TIMESTAMP() dependendo do sistema de gerenciamento de banco de dados
    END IF;
END;
//
DELIMITER ;

-- PROCEDURE FILTRAR ENTREGAS POR FUNCIONÁRIO

DELIMITER //
CREATE PROCEDURE filtrar_entregas_por_funcionario (
    IN p_idFUNCIONARIO INT
)
BEGIN
    SELECT
	f.idFUNCIONARIO,
        f.nome_funcionario,
        e.nome_epi,
        e.idEPI,
        fe.data_e_hora,
        fe.situacao_entrega,
        fe.quantidade_entregue,
        fe.descricao_entrega
    FROM
        funcionario_epi fe
    JOIN
        funcionario f ON fe.FUNCIONARIO_idFUNCIONARIO = f.idFUNCIONARIO
    JOIN
        epi e ON fe.EPI_idEPI = e.idEPI
    WHERE
        fe.FUNCIONARIO_idFUNCIONARIO = p_idFUNCIONARIO
    ORDER BY
        fe.data_e_hora DESC;
END //
DELIMITER ;

-- PROCEDURE FILTRAR ESTOQUE DE EPI

DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `filtrar_estoque_epi`(
    IN p_idEPI INT
)
BEGIN
    -- Verificar se o ID do EPI foi fornecido
    IF p_idEPI IS NOT NULL THEN
        -- Filtrar pelo ID do EPI
        SELECT idEPI, nome_epi, quantidade_estoque
        FROM epi
        WHERE idEPI = p_idEPI;
    ELSE
        -- Se nenhum ID do EPI foi fornecido, retornar uma mensagem de erro
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nenhum ID de EPI fornecido.';
    END IF;
END
//
DELIMITER ;

-- TRIGGER ATUALIZAR ESTOQUE DE EPI

DELIMITER //
CREATE TRIGGER atualizar_estoque_epi
AFTER INSERT ON funcionario_epi
FOR EACH ROW
BEGIN

    -- Atualiza o estoque do EPI

    UPDATE epi
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade_entregue
    WHERE idEPI = NEW.EPI_idEPI;


END //
DELIMITER ;

-- TRIGGER QUE EMITE UM ALERTA AO ATINGIR ESTOQUE MÍNIMO

DELIMITER //

CREATE TRIGGER alerta_estoque_minimo AFTER UPDATE ON epi
FOR EACH ROW
BEGIN
    DECLARE v_quantidade_minima INT;

    -- Defina a quantidade mínima desejada
    SET v_quantidade_minima = 10; -- Você pode ajustar esse valor conforme necessário

    -- Verifique se a nova quantidade de estoque é menor ou igual à quantidade mínima
    IF NEW.quantidade_estoque <= v_quantidade_minima THEN
        -- Emita um alerta usando a função SIGNAL
        SET @alerta_message = CONCAT('Alerta: A quantidade de estoque do EPI ', NEW.nome_epi, ' atingiu a quantidade mínima de ', v_quantidade_minima, '.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @alerta_message;
    END IF;
END;
//

DELIMITER ; 


-- FUNCTION QUE RETORNA A QUANTIDADE EM ESTOQUE DE UM EPI ESPECÍFICO

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `estoque_epi_especifico`(p_idEPI INT
) RETURNS int(11)
BEGIN
    DECLARE v_quantidade_estoque INT;
    
    SELECT quantidade_estoque INTO v_quantidade_estoque
    FROM epi
    WHERE idEPI = p_idEPI;

    RETURN v_quantidade_estoque;
END

//
DELIMITER ;