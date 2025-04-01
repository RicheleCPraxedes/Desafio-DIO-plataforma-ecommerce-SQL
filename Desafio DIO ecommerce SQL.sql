CREATE SCHEMA IF NOT EXISTS `ecommerce` DEFAULT CHARACTER SET utf8;
USE `ecommerce`;
CREATE TABLE IF NOT EXISTS `cliente` (
  `idcliente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cpf_cnpj` VARCHAR(18) NULL UNIQUE,
  `endereco` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`idcliente`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `pagamento` (
  `idpagamento` INT NOT NULL AUTO_INCREMENT,
  `tipo` ENUM('boleto', 'cartao_credito', 'cartao_debito', 'pix') NOT NULL,
  `codigo_transacao` VARCHAR(100) NULL UNIQUE,
  PRIMARY KEY (`idpagamento`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `pedido` (
  `idpedido` INT NOT NULL AUTO_INCREMENT,
  `status_pedido` ENUM('pendente', 'pago', 'enviado', 'entregue', 'cancelado') NOT NULL DEFAULT 'pendente',
  `descricao` VARCHAR(255) NULL,
  `frete` DECIMAL(10,2) NULL,
  `idcliente` INT NOT NULL,
  `idpagamento` INT NOT NULL,
  PRIMARY KEY (`idpedido`),
  FOREIGN KEY (`idcliente`) REFERENCES `cliente`(`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`idpagamento`) REFERENCES `pagamento`(`idpagamento`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `entrega` (
  `identrega` INT NOT NULL AUTO_INCREMENT,
  `status_entrega` ENUM('pendente', 'em_transporte', 'entregue') NOT NULL DEFAULT 'pendente',
  `codigo_rastreio` VARCHAR(50) NULL UNIQUE,
  PRIMARY KEY (`identrega`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `produto` (
  `idproduto` INT NOT NULL AUTO_INCREMENT,
  `categoria` VARCHAR(100) NOT NULL,
  `descricao` VARCHAR(255) NULL,
  `valor` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`idproduto`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `pedido_produto` (
  `idpedido` INT NOT NULL,
  `idproduto` INT NOT NULL,
  `quantidade` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`idpedido`, `idproduto`),
  FOREIGN KEY (`idpedido`) REFERENCES `pedido`(`idpedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`idproduto`) REFERENCES `produto`(`idproduto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `estoque` (
  `idestoque` INT NOT NULL AUTO_INCREMENT,
  `localizacao` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`idestoque`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `produto_estoque` (
  `idproduto` INT NOT NULL,
  `idestoque` INT NOT NULL,
  `quantidade` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`idproduto`, `idestoque`),
  FOREIGN KEY (`idproduto`) REFERENCES `produto`(`idproduto`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`idestoque`) REFERENCES `estoque`(`idestoque`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `fornecedor` (
  `idfornecedor` INT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(255) NOT NULL,
  `cnpj` VARCHAR(18) NOT NULL UNIQUE,
  PRIMARY KEY (`idfornecedor`)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `produto_fornecedor` (
  `idfornecedor` INT NOT NULL,
  `idproduto` INT NOT NULL,
  PRIMARY KEY (`idfornecedor`, `idproduto`),
  FOREIGN KEY (`idfornecedor`) REFERENCES `fornecedor`(`idfornecedor`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`idproduto`) REFERENCES `produto`(`idproduto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `pessoa` (
  `idpessoa` INT NOT NULL AUTO_INCREMENT,
  `cpf_cnpj` VARCHAR(18) NOT NULL UNIQUE,
  `nome_razao_social` VARCHAR(255) NOT NULL,
  `tipo` ENUM('cliente', 'terceiro') NOT NULL,
  `idcliente` INT NULL,
  `idfornecedor` INT NULL,
  PRIMARY KEY (`idpessoa`),
  FOREIGN KEY (`idcliente`) REFERENCES `cliente`(`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (`idfornecedor`) REFERENCES `fornecedor`(`idfornecedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB;

SELECT idcliente, nome, cpf_cnpj, endereco 
FROM cliente 
ORDER BY nome ASC;

SELECT idpedido, status_pedido, descricao, frete, idcliente, idpagamento 
FROM pedido 
ORDER BY idpedido DESC;

SELECT pe.idproduto, p.descricao, pe.idestoque, e.localizacao, pe.quantidade 
FROM produto_estoque pe
JOIN produto p ON pe.idproduto = p.idproduto
JOIN estoque e ON pe.idestoque = e.idestoque
ORDER BY pe.quantidade DESC;

SELECT idpedido, status_pedido, descricao, frete, idcliente 
FROM pedido 
WHERE frete > 50;

SELECT idcliente, COUNT(idpedido) AS total_pedidos
FROM pedido
GROUP BY idcliente
HAVING total_pedidos > 3;

SELECT categoria, COUNT(idproduto) AS total_produtos, AVG(valor) AS preco_medio
FROM produto
WHERE valor > 100
GROUP BY categoria;

