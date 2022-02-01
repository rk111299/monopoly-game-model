# CREATING THE RELATIONAL DATABASE SCHEMA

CREATE TABLE Locations (
    LocationId INT NOT NULL PRIMARY KEY
);

CREATE TABLE Bonuses (
    BonusID INT NOT NULL,
    Name VARCHAR(50) PRIMARY KEY,
    Description VARCHAR(200)
);

CREATE TABLE Properties (
    PropertyId INT NOT NULL,
    Name VARCHAR(30) PRIMARY KEY, 
    Cost INT NOT NULL,
    Colour VARCHAR(20)
);

CREATE TABLE Players (
    PlayerId INT NOT NULL,
    Token VARCHAR(15) PRIMARY KEY,
    Name VARCHAR(10),
    BankBalance INT NOT NULL,
    CurrentLocation INT NOT NULL,
    CurrentBonus VARCHAR(50),
    GameRound INT,
    TurnId INT,
    FOREIGN KEY (CurrentLocation) REFERENCES Locations(LocationId),
    FOREIGN KEY (CurrentBonus) REFERENCES Bonuses(Name)
);

CREATE TABLE OwnedProperties (
    LandlordToken VARCHAR(15),
    OwnedProperty VARCHAR(30),
    PRIMARY KEY (LandlordToken, OwnedProperty),
    FOREIGN KEY (LandlordToken) REFERENCES Players(Token),
    FOREIGN KEY (OwnedProperty) REFERENCES Properties(Name)
);


CREATE TABLE AuditTrail (
    AuditId INT AUTO_INCREMENT PRIMARY KEY,
    Token VARCHAR(15), 
    CurrentLocation VARCHAR(30),
    BankBalance INT,
    GameRound INT,
    TurnId INT
);

# INSERTING VALUES INTO THE DATABASE

INSERT INTO Locations VALUES
    (1), (2), (3), (4),
    (5), (6), (7), (8),
    (9), (10), (11), (12),
    (13), (14), (15), (16);


INSERT INTO Properties VALUES
    (2, 'Kilburn', 120, 'Yellow'),
    (4, 'Uni Place', 100, 'Yellow'),
    (6, 'Victoria', 75, 'Green'),
    (8, 'Piccadilly', 35, 'Green'),
    (10, 'Oak House', 100, 'Orange'),
    (12, 'Owens Park', 30, 'Orange'),
    (14, 'AMBS', 400, 'Blue'),
    (16, 'Co-op', 30, 'Blue');

INSERT INTO Bonuses VALUES
    (0, 'No Bonus', 'No Bonus'),
    (1, 'GO', 'Collect £200'),
    (3, 'Chance 1', 'Pay each of the other players £50'),
    (5, 'Jail', 'You must roll a 6 to get out'),
    (7, 'Community Chest 1', 'For winning a beauty contest, you win £100'),
    (9, 'Free Parking', 'No action'),
    (11, 'Chance 2', 'Move forward 3 spaces'),
    (13, 'Go to Jail', 'Go to jail, do not pass GO, do not collect £200'),
    (15, 'Community Chest 2', 'Your library books are overdue. Pay a fine of £30');

INSERT INTO Players VALUES
    (1, 'Battleship', 'Mary', 190, 9, NULL, NULL, NULL),
    (2, 'Dog', 'Bill', 500, 12, NULL, NULL, NULL),
    (3, 'Car', 'Jane', 150, 14, NULL, NULL, NULL),
    (4, 'Thimble', 'Norman', 250, 2, NULL, NULL, NULL);

INSERT INTO OwnedProperties VALUES
    ('Battleship', 'Uni Place'),
    ('Dog', 'Victoria'),
    ('Car', 'Co-op'),
    ('Thimble', 'Oak House'),
    ('Thimble', 'Owens Park');


# CREATING A TRIGGER FOR THE AUDIT TRAIL

DELIMITER $$
CREATE TRIGGER AuditTrail AFTER UPDATE ON Players
FOR EACH ROW
BEGIN
    INSERT INTO AuditTrail (Token, CurrentLocation, BankBalance, GameRound, TurnId)
    VALUES(NEW.Token, NEW.CurrentLocation, NEW.BankBalance, NEW.GameRound,
    NEW.TurnId);
END$$


# GAMEVIEW OF CURRENT STATE OF PLAY

CREATE VIEW gameView0 AS SELECT * FROM Players
LEFT JOIN OwnedProperties
ON Players.Token = OwnedProperties.LandlordToken;


# GAMEPLAY SIMULATION - GAMEROUND 1

# GameRound 1, Turn 1 - Jane rolls a 3
UPDATE Players
SET BankBalance=BankBalance+200, CurrentLocation = 1, CurrentBonus = 'GO',
GameRound = 1, TurnId = 1
WHERE Players.Token = 'Car';

# GameRound 1, Turn 2 - Norman rolls a 1
UPDATE Players 
SET BankBalance=BankBalance-150, CurrentLocation=3, CurrentBonus = 'Chance 1',
GameRound = 1, TurnId = 2
WHERE Players.Token = 'Thimble';

UPDATE Players
SET BankBalance=BankBalance+50, GameRound=1, TurnId=2
WHERE Players.Token != 'Thimble';

# GameRound 1, Turn 3 - Mary rolls a 4
UPDATE Players
SET CurrentLocation=5, CurrentBonus='Jail', GameRound=1, TurnId=3
WHERE Players.Token = 'Battleship';

# GameRound 1, Turn 4 - Bill rolls a 2
UPDATE Players
SET BankBalance=BankBalance-400, CurrentLocation=14, GameRound=1,
TurnId = 4
WHERE Players.Token = 'Dog';

INSERT INTO OwnedProperties VALUES
    ('Dog', 'AMBS');


# GAMEVIEW AFTER GAMEROUND 1

CREATE VIEW gameView1 AS SELECT * FROM Players
LEFT JOIN OwnedProperties
ON Players.Token = OwnedProperties.LandlordToken;

# GAMEPLAY SIMULATION - GAMEROUND 1

# GameRound 2, Turn 5 - Jane rolls a 5
UPDATE Players
SET BankBalance=BankBalance-75, CurrentLocation=CurrentLocation+5, 
CurrentBonus = 'No Bonus', GameRound=2, TurnId=5
WHERE Players.Token = 'Car';

UPDATE Players
SET BankBalance=BankBalance+75
WHERE Players.Token = 'Dog';

# GameRound 2, Turn 6 - Norman Rolls a 4
UPDATE Players
SET BankBalance=BankBalance+100, CurrentLocation=CurrentLocation+4,
CurrentBonus='Community Chest 1', GameRound=2, TurnId=6
WHERE Players.Token = 'Thimble';

# GameRound 2, Turn 7 - Mary rolls a 6, then a 5
UPDATE Players
SET CurrentBonus='No Bonus', GameRound=2, TurnId=7
WHERE Players.Token = 'Battleship';

UPDATE Players
SET BankBalance=BankBalance-200, CurrentLocation=CurrentLocation+5
WHERE Players.Token = 'Battleship';

UPDATE Players
SET BankBalance=BankBalance+200
WHERE Players.Token = 'Thimble';

# GameRound 2, Turn 8 - Bill rolls a 6, and then a 3
UPDATE Players
SET BankBalance=BankBalance+200, CurrentLocation=4, GameRound=2,
TurnId=8 
WHERE Players.Token = 'Dog';

UPDATE Players
SET CurrentLocation=CurrentLocation+3, CurrentBonus='Free Parking'
WHERE Players.Token = 'Dog';

# GAMEVIEW AFTER GAMEROUND 

CREATE VIEW gameView2 AS SELECT * FROM Players
LEFT JOIN OwnedProperties
ON Players.Token = OwnedProperties.LandlordToken