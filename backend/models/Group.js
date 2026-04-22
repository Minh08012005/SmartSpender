const mongoose = require('mongoose');

const groupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Tên nhóm là bắt buộc'],
    minlength: [3, 'Tên nhóm phải từ 3 ký tự trở lên'],
    maxlength: [50, 'Tên nhóm không được vượt quá 50 ký tự']
  },
  description: {
    type: String,
    maxlength: [200, 'Mô tả không được vượt quá 200 ký tự']
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', // Liên kết tới model User
    required: true
  },
  members: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    role: { type: String, enum: ['admin', 'member'], default: 'admin' },
    joinedAt: { type: Date, default: Date.now }
  }]
}, { 
  timestamps: true // Tự động sinh ra createdAt và updatedAt
});

module.exports = mongoose.model('Group', groupSchema);