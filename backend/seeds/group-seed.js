/**
 * File: backend/seeds/group-seed.js
 * Mục tiêu: Tạo mock data cho group feature
 *
 * Cách chạy:
 *   node backend/seeds/group-seed.js
 *
 * Dữ liệu sẽ tạo:
 *   - 3 groups: Du lịch Nha Trang, Nhà, Du lịch Bali
 *   - 10 members (3 admin, 7 member)
 *   - 5 wallets (2-3 per group)
 *   - 15 sample transactions (cho wallets)
 */

const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcrypt');

// Load environment variables
dotenv.config();

// Connect to MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(
      process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/smartspender'
    );
    console.log('✅ Connected to MongoDB');
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error.message);
    process.exit(1);
  }
};

// Define temporary schemas for seeding (nếu chưa have models)
// Nếu có models rồi, hãy import từ models folder

// Seed function
const seedGroupData = async () => {
  try {
    console.log('\n🌱 STARTING GROUP DATA SEEDING...\n');

    // ------- STEP 0: Create Test User -------
    console.log('👤 Creating test user...');

    const testEmail = 'test@example.com';
    const testPassword = await bcrypt.hash('password123', 10);

    const testUser = {
      email: testEmail,
      password: testPassword,
      fullName: 'Test User',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Delete old test user if exists
    await mongoose.connection
      .collection('users')
      .deleteOne({ email: testEmail });

    const userResult = await mongoose.connection
      .collection('users')
      .insertOne(testUser);

    const testUserId = userResult.insertedId;
    console.log(`✅ Test user created: ${testEmail} (ID: ${testUserId})\n`);

    // Get reference users (giả sử đã có users trong database)
    // ⚠️ IMPORTANT: Thay đổi những ObjectId này thành real user IDs từ database của bạn
    const SAMPLE_USER_IDS = [
      '6984b8a8935d2032ea50e5d0',
      '698560b5b164ff1b9c18bf96',
      '699c0769f84e0aa1d92acf38',
      '69bfb5a8e3548d25f10af074',
      '69bfc8b2b02819fd748a914f',
      '69bfc971b02819fd748a9153',
      '69bfca09b02819fd748a9159',
      '69bfe81203bf68e8219e9d59',
      '69bfeadee51340f844ab1dfc',
      '69bfeb52e51340f844ab1dff',
    ];

    // ------- STEP 1: Clear old data -------
    console.log('📝 Clearing old group data...');

    await mongoose.connection.collection('groups').deleteMany({});
    await mongoose.connection.collection('group_members').deleteMany({});
    await mongoose.connection.collection('group_wallets').deleteMany({});

    console.log('✅ Cleared old data\n');

    // ------- STEP 2: Create 3 Groups -------
    console.log('🏢 Creating 3 groups...');

    const groupsData = [
      {
        name: 'Du lịch Nha Trang',
        description: 'Chuyến đi tháng 5 cùng bạn bè từ Tp.HCM',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-14'),
        updatedAt: new Date('2026-04-14'),
      },
      {
        name: 'Nhóm nhà',
        description: 'Chi tiêu chung nhà ở Sài Gòn',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        createdAt: new Date('2026-04-10'),
        updatedAt: new Date('2026-04-10'),
      },
      {
        name: 'Du lịch Bali',
        description: 'Chuyến đi tháng 6 - Bali, Indonesia',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-05'),
        updatedAt: new Date('2026-04-05'),
      },
    ];

    const groupsResult = await mongoose.connection
      .collection('groups')
      .insertMany(groupsData);
    const groupIds = Object.values(groupsResult.insertedIds);

    console.log(`✅ Created ${groupIds.length} groups:`);
    groupIds.forEach((id, idx) => {
      console.log(`   ${idx + 1}. ${groupsData[idx].name} (ID: ${id})`);
    });
    console.log();

    // ------- STEP 3: Create 10 Members -------
    console.log('👥 Creating 10 members...');

    const membersData = [
      // Group 1 members (Du lịch Nha Trang)
      {
        groupId: groupIds[0],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        role: 'admin',
        joinedAt: new Date('2026-04-14'),
      },
      {
        groupId: groupIds[0],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        role: 'member',
        joinedAt: new Date('2026-04-14'),
      },
      {
        groupId: groupIds[0],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[2]),
        role: 'member',
        joinedAt: new Date('2026-04-14'),
      },

      // Group 2 members (Nhóm nhà)
      {
        groupId: groupIds[1],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        role: 'admin',
        joinedAt: new Date('2026-04-10'),
      },
      {
        groupId: groupIds[1],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[3]),
        role: 'member',
        joinedAt: new Date('2026-04-10'),
      },
      {
        groupId: groupIds[1],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[4]),
        role: 'member',
        joinedAt: new Date('2026-04-11'),
      },
      {
        groupId: groupIds[1],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[5]),
        role: 'viewer',
        joinedAt: new Date('2026-04-12'),
      },

      // Group 3 members (Du lịch Bali)
      {
        groupId: groupIds[2],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        role: 'admin',
        joinedAt: new Date('2026-04-05'),
      },
      {
        groupId: groupIds[2],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[6]),
        role: 'member',
        joinedAt: new Date('2026-04-06'),
      },
      {
        groupId: groupIds[2],
        userId: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[7]),
        role: 'member',
        joinedAt: new Date('2026-04-07'),
      },
    ];

    const membersResult = await mongoose.connection
      .collection('group_members')
      .insertMany(membersData);

    console.log(
      `✅ Created ${Object.keys(membersResult.insertedIds).length} members`
    );
    console.log(
      '   Group 1 (Du lịch Nha Trang): 3 members (1 admin, 2 member)'
    );
    console.log(
      '   Group 2 (Nhóm nhà): 4 members (1 admin, 2 member, 1 viewer)'
    );
    console.log('   Group 3 (Du lịch Bali): 3 members (1 admin, 2 member)');
    console.log();

    // ------- STEP 4: Create 5 Wallets -------
    console.log('💳 Creating 5 wallets...');

    const walletsData = [
      // Group 1 wallets
      {
        groupId: groupIds[0],
        name: 'Quỹ chính',
        balance: 5000000,
        currency: 'VND',
        createdAt: new Date('2026-04-14'),
        updatedAt: new Date('2026-04-14'),
      },
      {
        groupId: groupIds[0],
        name: 'Quỹ ăn uống',
        balance: 2000000,
        currency: 'VND',
        createdAt: new Date('2026-04-14'),
        updatedAt: new Date('2026-04-14'),
      },

      // Group 2 wallets
      {
        groupId: groupIds[1],
        name: 'Quỹ nhà',
        balance: 3000000,
        currency: 'VND',
        createdAt: new Date('2026-04-10'),
        updatedAt: new Date('2026-04-14'),
      },

      // Group 3 wallets
      {
        groupId: groupIds[2],
        name: 'Quỹ chính Bali',
        balance: 8000000,
        currency: 'VND',
        createdAt: new Date('2026-04-05'),
        updatedAt: new Date('2026-04-05'),
      },
      {
        groupId: groupIds[2],
        name: 'Quỹ khách sạn',
        balance: 6000000,
        currency: 'VND',
        createdAt: new Date('2026-04-05'),
        updatedAt: new Date('2026-04-05'),
      },
    ];

    const walletsResult = await mongoose.connection
      .collection('group_wallets')
      .insertMany(walletsData);
    const walletIds = Object.values(walletsResult.insertedIds);

    console.log(`✅ Created ${walletIds.length} wallets`);
    walletsData.forEach((wallet, idx) => {
      console.log(
        `   ${idx + 1}. ${wallet.name}: ${wallet.balance.toLocaleString('vi-VN')} ${wallet.currency}`
      );
    });
    console.log();

    // ------- STEP 5: Create Sample Transactions (Optional) -------
    console.log('💰 Creating 15 sample transactions...');

    const transactionsData = [
      // Group 1 transactions
      {
        groupId: groupIds[0],
        walletId: walletIds[0],
        amount: 500000,
        type: 'expense',
        category: 'food',
        note: 'Tiền ăn cơm tối',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-14T12:00:00'),
      },
      {
        groupId: groupIds[0],
        walletId: walletIds[0],
        amount: 1000000,
        type: 'expense',
        category: 'transport',
        note: 'Tiền xe từ Tp.HCM đến Nha Trang',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        createdAt: new Date('2026-04-14T13:00:00'),
      },
      {
        groupId: groupIds[0],
        walletId: walletIds[1],
        amount: 2000000,
        type: 'income',
        category: 'contribution',
        note: 'Cơm từ Minh',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-14T08:00:00'),
      },
      {
        groupId: groupIds[0],
        walletId: walletIds[1],
        amount: 1500000,
        type: 'income',
        category: 'contribution',
        note: 'Tiền từ Nam',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        createdAt: new Date('2026-04-14T08:30:00'),
      },

      // Group 2 transactions
      {
        groupId: groupIds[1],
        walletId: walletIds[2],
        amount: 300000,
        type: 'expense',
        category: 'utilities',
        note: 'Tiền điện tháng 4',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        createdAt: new Date('2026-04-13T10:00:00'),
      },
      {
        groupId: groupIds[1],
        walletId: walletIds[2],
        amount: 500000,
        type: 'expense',
        category: 'groceries',
        note: 'Mua thực phẩm hàng tuần',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[3]),
        createdAt: new Date('2026-04-12T15:00:00'),
      },
      {
        groupId: groupIds[1],
        walletId: walletIds[2],
        amount: 1000000,
        type: 'expense',
        category: 'utilities',
        note: 'Tiền nước tháng 4',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[4]),
        createdAt: new Date('2026-04-12T14:00:00'),
      },
      {
        groupId: groupIds[1],
        walletId: walletIds[2],
        amount: 2000000,
        type: 'income',
        category: 'contribution',
        note: 'Đóng tiền từ Nam',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[1]),
        createdAt: new Date('2026-04-11T09:00:00'),
      },

      // Group 3 transactions
      {
        groupId: groupIds[2],
        walletId: walletIds[3],
        amount: 4000000,
        type: 'expense',
        category: 'accommodation',
        note: 'Tiền khách sạn 2 đêm',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-06T14:00:00'),
      },
      {
        groupId: groupIds[2],
        walletId: walletIds[3],
        amount: 1000000,
        type: 'expense',
        category: 'food',
        note: 'Tiền ăn sáng + chiều',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[6]),
        createdAt: new Date('2026-04-07T12:00:00'),
      },
      {
        groupId: groupIds[2],
        walletId: walletIds[4],
        amount: 3000000,
        type: 'expense',
        category: 'accommodation',
        note: 'Tiền khách sạn 3 đêm',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-06T15:00:00'),
      },
      {
        groupId: groupIds[2],
        walletId: walletIds[4],
        amount: 500000,
        type: 'expense',
        category: 'entertainment',
        note: 'Tour Ubud + mua khôm',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[7]),
        createdAt: new Date('2026-04-07T11:00:00'),
      },
      {
        groupId: groupIds[2],
        walletId: walletIds[3],
        amount: 5000000,
        type: 'income',
        category: 'contribution',
        note: 'Tiền từ 3 người',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-05T18:00:00'),
      },
      {
        groupId: groupIds[2],
        walletId: walletIds[4],
        amount: 3000000,
        type: 'income',
        category: 'contribution',
        note: 'Tiền từ Ngọc Anh + Xuân',
        createdBy: new mongoose.Types.ObjectId(SAMPLE_USER_IDS[0]),
        createdAt: new Date('2026-04-05T19:00:00'),
      },
    ];

    const transactionsResult = await mongoose.connection
      .collection('transactions')
      .insertMany(transactionsData);

    console.log(
      `✅ Created ${Object.keys(transactionsResult.insertedIds).length} transactions\n`
    );

    // ------- STEP 6: Summary -------
    console.log('📊 SEEDING SUMMARY:');
    console.log('==========================================');
    console.log(`✅ Groups created: 3`);
    console.log(`✅ Members created: 10`);
    console.log(`✅ Wallets created: 5`);
    console.log(`✅ Transactions created: 15`);
    console.log('==========================================\n');

    console.log('🎉 SEEDING COMPLETED SUCCESSFULLY!\n');

    // Display Group IDs for reference
    console.log('📌 GROUP IDs (use for testing):');
    groupIds.forEach((id, idx) => {
      console.log(`   Group ${idx + 1}: ${id}`);
    });

    console.log('\n📌 WALLET IDs (use for testing):');
    walletIds.forEach((id, idx) => {
      console.log(`   Wallet ${idx + 1}: ${id}`);
    });

    console.log('\n⚠️  Important Notes:');
    console.log(
      '   1. Replace SAMPLE_USER_IDS with real user IDs from your database'
    );
    console.log('   2. This seed data is for development/testing only');
    console.log(
      "   3. Run 'node backend/seeds/group-seed.js' to populate data\n"
    );
  } catch (error) {
    console.error('❌ SEEDING FAILED:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
  } finally {
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('✅ Disconnected from MongoDB\n');
  }
};

// Run seeding
(async () => {
  await connectDB();
  await seedGroupData();
})();
