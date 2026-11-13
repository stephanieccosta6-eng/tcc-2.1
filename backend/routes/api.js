const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();
const User = require('../models/User');
const Fridge = require('../models/Fridge');
const Order = require('../models/Order');

const STRONG_PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/~`]).{8,}$/;

const runtimeUsers = new Map();
let runtimeFridge = { temperature: 6.0, mode: 'Ideal' };

router.get('/status', (req, res) => {
  res.json({ status: 'online', dbConnected: req.dbConnected });
});

router.post('/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !email.includes('@')) {
      return res.status(400).json({ error: 'Informe nome e um e-mail válido contendo @.' });
    }
    if (!STRONG_PASSWORD_REGEX.test(password || '')) {
      return res.status(400).json({
        error: 'A senha deve ter no mínimo 8 caracteres, com letra maiúscula, minúscula, número e caractere especial.'
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    if (req.dbConnected) {
      const existing = await User.findOne({ email: email.toLowerCase() });
      if (existing) {
        return res.status(409).json({ error: 'Este e-mail já está cadastrado.' });
      }
      const user = await User.create({
        name: name.trim(),
        email: email.toLowerCase().trim(),
        password: hashedPassword,
        lgpdAccepted: true
      });
      return res.status(201).json({
        user: { id: user._id, name: user.name, email: user.email, skinType: user.skinType, skinGoal: user.skinGoal }
      });
    }

    if (runtimeUsers.has(email.toLowerCase())) {
      return res.status(409).json({ error: 'Este e-mail já está cadastrado.' });
    }
    const newUser = { name: name.trim(), email: email.toLowerCase().trim(), password: hashedPassword, skinType: null, skinGoal: null };
    runtimeUsers.set(newUser.email, newUser);
    return res.status(201).json({ user: { name: newUser.name, email: newUser.email, skinType: null, skinGoal: null } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Preencha e-mail e senha.' });
    }

    if (req.dbConnected) {
      const user = await User.findOne({ email: email.toLowerCase().trim() });
      if (!user) {
        return res.status(401).json({ error: 'Usuário não encontrado. Crie uma conta primeiro.' });
      }
      const isMatch = await bcrypt.compare(password, user.password);
      if (!isMatch) {
        return res.status(401).json({ error: 'Senha incorreta.' });
      }
      const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secret', { expiresIn: '7d' });
      return res.json({
        token,
        user: { id: user._id, name: user.name, email: user.email, skinType: user.skinType, skinGoal: user.skinGoal }
      });
    }

    const user = runtimeUsers.get(email.toLowerCase().trim());
    if (!user) {
      return res.status(401).json({ error: 'Usuário não encontrado. Crie uma conta primeiro.' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Senha incorreta.' });
    }
    return res.json({ user: { name: user.name, email: user.email, skinType: user.skinType, skinGoal: user.skinGoal } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/user/quiz', async (req, res) => {
  const { email, skinType, skinGoal } = req.body;
  try {
    if (req.dbConnected && email) {
      const user = await User.findOneAndUpdate(
        { email: email.toLowerCase() },
        { skinType, skinGoal },
        { new: true }
      );
      return res.json({ success: true, user });
    }
    if (email && runtimeUsers.has(email.toLowerCase())) {
      const u = runtimeUsers.get(email.toLowerCase());
      u.skinType = skinType;
      u.skinGoal = skinGoal;
    }
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/fridge', async (req, res) => {
  try {
    if (req.dbConnected) {
      let fridge = await Fridge.findOne();
      if (!fridge) fridge = await Fridge.create({ ownerEmail: 'geral@glowup.com', temperature: 6.0, mode: 'Ideal' });
      return res.json(fridge);
    }
    res.json(runtimeFridge);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/fridge/temperature', async (req, res) => {
  const { temperature } = req.body;
  const mode = temperature >= 4 && temperature <= 8 ? 'Ideal' : 'Alerta';
  try {
    if (req.dbConnected) {
      const fridge = await Fridge.findOneAndUpdate({}, { temperature, mode, updatedAt: new Date() }, { upsert: true, new: true });
      return res.json(fridge);
    }
    runtimeFridge = { temperature, mode };
    res.json(runtimeFridge);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/orders', async (req, res) => {
  const { customerName, customerEmail, items, total } = req.body;
  try {
    if (req.dbConnected) {
      const order = await Order.create({ customerName, customerEmail, items, total });
      return res.status(201).json({ success: true, order });
    }
    res.status(201).json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
