CREATE TABLE artists (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
);

CREATE TABLE records (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  artist_id INTEGER NOT NULL

  FOREIGN KEY(artist_id) REFERENCES artist(id)
);

CREATE TABLE tracks (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  record_id INTEGER NOT NULL,

  FOREIGN KEY(record_id) REFERENCES record(id)
);



INSERT INTO
  artists (id, fname, lname)
VALUES
  (1, "Taylor", "Swift"), (2, "Ed", "Sheeran");

INSERT INTO
  records (id, name, artist_id)
VALUES
  (1, "reputation", 1),
  (2, "Red", 1),
  (3, "Divide", 2);

INSERT INTO
  tracks (id, name, record_id)
VALUES
  (1, ".Ready for It?", 1),
  (2, "Gorgeous", 1),
  (3, "New Year's Day", 1),
  (4, "All Too Well", 2),
  (4, "Begin Again", 2),
  (4, "Holy Ground", 2),
  (4, "Castle on the Hill", 3),
  (4, "Eraser", 3);
