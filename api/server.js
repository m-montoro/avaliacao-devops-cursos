const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");

const app = express();

app.use(cors({
  origin: process.env.CORS_ORIGIN || "http://localhost:8181"
}));

app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || "mysql",
  user: process.env.DB_USER || "cursos",
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || "cursos_db",
  waitForConnections: true,
  connectionLimit: 10
});

app.get("/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", database: "connected" });
  } catch (error) {
    res.status(503).json({
      status: "error",
      database: "unavailable"
    });
  }
});

app.post("/curso", async (req, res) => {
  try {
    const { nome, instrutor, preco, vagas } = req.body;

    if (
      typeof nome !== "string" ||
      typeof instrutor !== "string" ||
      !nome.trim() ||
      !instrutor.trim() ||
      nome.length > 150 ||
      instrutor.length > 150 ||
      preco === "" ||
      preco === null ||
      preco === undefined ||
      vagas === "" ||
      vagas === null ||
      vagas === undefined ||
      !Number.isFinite(Number(preco)) ||
      Number(preco) < 0 ||
      !Number.isInteger(Number(vagas)) ||
      Number(vagas) < 0 ||
      Number(vagas) > 2147483647
    ) {
      return res.status(400).json({
        erro: "Dados invalidos. Informe nome, instrutor, preco e vagas."
      });
    }

    const [resultado] = await pool.execute(
      "INSERT INTO cursos (nome, instrutor, preco, vagas) VALUES (?, ?, ?, ?)",
      [nome.trim(), instrutor.trim(), Number(preco), Number(vagas)]
    );

    res.status(201).json({
      mensagem: "Curso cadastrado com sucesso",
      id: resultado.insertId
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ erro: "Erro ao cadastrar curso" });
  }
});

app.get("/cursos", async (req, res) => {
  try {
    const [cursos] = await pool.query(
      "SELECT id, nome, instrutor, preco, vagas FROM cursos ORDER BY id DESC"
    );

    res.json(cursos);
  } catch (error) {
    console.error(error);
    res.status(500).json({ erro: "Erro ao listar cursos" });
  }
});

app.listen(3000, "0.0.0.0", () => {
  console.log("API executando na porta 3000");
});
