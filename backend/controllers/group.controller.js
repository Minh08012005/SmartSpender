const Group = require('../models/Group');

// 1️⃣ Tạo nhóm mới
exports.createGroup = async (req, res) => {
  try {
    const { name, description } = req.body;
    const userId = req.user._id; // Lấy từ JWT Token sau khi đi qua Middleware

    // Tạo nhóm mới với user hiện tại là người tạo và là admin
    const newGroup = await Group.create({
      name,
      description,
      createdBy: userId,
      members: [{ userId: userId, role: 'admin' }]
    });

    res.status(201).json({
      success: true,
      data: {
        groupId: newGroup._id,
        name: newGroup.name,
        description: newGroup.description,
        createdBy: newGroup.createdBy,
        memberCount: newGroup.members.length,
        createdAt: newGroup.createdAt,
        updatedAt: newGroup.updatedAt
      }
    });
  } catch (error) {
    // Nếu lỗi do validation của Mongoose (ví dụ: tên < 3 ký tự)
    if (error.name === 'ValidationError') {
      return res.status(400).json({ success: false, message: error.message });
    }
    res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// 2️⃣ Lấy danh sách nhóm của user
exports.getGroups = async (req, res) => {
  try {
    const userId = req.user._id; 
    const skip = parseInt(req.query.skip) || 0;
    const limit = parseInt(req.query.limit) || 10;

    // Tìm các nhóm mà user này có trong danh sách members
    const groups = await Group.find({ "members.userId": userId })
      .sort({ createdAt: -1 }) // Sắp xếp mới nhất lên đầu
      .skip(skip)
      .limit(limit);

    // Đếm tổng số nhóm để trả về cho phân trang
    const total = await Group.countDocuments({ "members.userId": userId });

    // Format lại dữ liệu trả về theo đúng chuẩn API spec
    const formattedGroups = groups.map(group => ({
      groupId: group._id,
      name: group.name,
      description: group.description,
      memberCount: group.members.length,
      createdBy: group.createdBy,
      createdAt: group.createdAt
    }));

    res.status(200).json({
      success: true,
      data: formattedGroups,
      total,
      page: Math.floor(skip / limit) + 1
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// 3️⃣ Xem chi tiết 1 nhóm
exports.getGroupById = async (req, res) => {
  try {
    const userId = req.user._id; 
    const { groupId } = req.params;

    // Tìm nhóm và kết nối (populate) để lấy thêm thông tin email của user
    const group = await Group.findById(groupId)
      .populate('createdBy', 'email')
      .populate('members.userId', 'email');

    if (!group) {
      return res.status(404).json({ success: false, message: 'Nhóm không tồn tại' });
    }

    // Kiểm tra xem user hiện tại có phải là thành viên không
    const isMember = group.members.some(member => member.userId._id.toString() === userId.toString());
    if (!isMember) {
      return res.status(403).json({ success: false, message: 'Bạn không có quyền xem nhóm này' });
    }

    // Format dữ liệu trả về (Lưu ý: Phần wallets tạm thời để mảng rỗng vì bạn làm Group API, Wallet API do bạn khác làm)
    const formattedGroup = {
      groupId: group._id,
      name: group.name,
      description: group.description,
      createdBy: group.createdBy,
      members: group.members,
      wallets: [], // Sẽ kết nối sau nếu nhóm bạn có Model Wallet
      createdAt: group.createdAt
    };

    res.status(200).json({ success: true, data: formattedGroup });
  } catch (error) {
    if (error.kind === 'ObjectId') return res.status(404).json({ success: false, message: 'ID nhóm không hợp lệ' });
    res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// 4️⃣ Cập nhật nhóm
exports.updateGroup = async (req, res) => {
  try {
    const userId = req.user._id; 
    const { groupId } = req.params;
    const { name, description } = req.body;

    const group = await Group.findById(groupId);
    if (!group) return res.status(404).json({ success: false, message: 'Nhóm không tồn tại' });

    // Cực kỳ quan trọng: Kiểm tra quyền Admin
    const isAdmin = group.members.some(
      member => member.userId.toString() === userId.toString() && member.role === 'admin'
    );
    if (!isAdmin) {
      return res.status(403).json({ success: false, message: 'Chỉ Admin mới được cập nhật nhóm' });
    }

    // Cập nhật
    if (name) group.name = name;
    if (description) group.description = description;
    await group.save();

    res.status(200).json({
      success: true,
      data: {
        groupId: group._id,
        name: group.name,
        description: group.description,
        updatedAt: group.updatedAt
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};

// 5️⃣ Xóa nhóm
exports.deleteGroup = async (req, res) => {
  try {
    const userId = req.user._id; 
    const { groupId } = req.params;

    const group = await Group.findById(groupId);
    if (!group) return res.status(404).json({ success: false, message: 'Nhóm không tồn tại' });

    // Cực kỳ quan trọng: Kiểm tra quyền Admin
    const isAdmin = group.members.some(
      member => member.userId.toString() === userId.toString() && member.role === 'admin'
    );
    if (!isAdmin) {
      return res.status(403).json({ success: false, message: 'Chỉ Admin mới được xóa nhóm' });
    }

    await Group.findByIdAndDelete(groupId);

    res.status(200).json({ success: true, message: 'Nhóm đã bị xóa thành công' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Lỗi server' });
  }
};