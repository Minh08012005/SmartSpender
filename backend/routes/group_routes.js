const express = require('express');
const router = express.Router();
const groupController = require('../controllers/group.controller');
const authenticate = require('../middleware/auth.middleware'); 

// Áp dụng middleware kiểm tra Token cho TOÀN BỘ routes của file này
router.use(authenticate);

// Gắn các đường dẫn vào hàm tương ứng
router.post('/', groupController.createGroup);          // 1️⃣ Tạo nhóm
router.get('/', groupController.getGroups);             // 2️⃣ Danh sách nhóm
router.get('/:groupId', groupController.getGroupById);  // 3️⃣ Chi tiết nhóm
router.patch('/:groupId', groupController.updateGroup); // 4️⃣ Cập nhật nhóm
router.delete('/:groupId', groupController.deleteGroup);// 5️⃣ Xóa nhóm

module.exports = router;