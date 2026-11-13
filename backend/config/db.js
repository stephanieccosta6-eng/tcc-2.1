const mongoose = require('mongoose');

const connectDB = async () => {
  if (!process.env.MONGODB_URI || process.env.MONGODB_URI.includes('SUA_SENHA_AQUI')) {
    console.warn('⚠️ Configure MONGODB_URI no arquivo .env para persistência no MongoDB Atlas.');
    return false;
  }
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Conectado ao MongoDB Atlas com sucesso!');
    return true;
  } catch (err) {
    console.error('❌ Erro ao conectar no MongoDB Atlas:', err.message);
    return false;
  }
};

module.exports = connectDB;
