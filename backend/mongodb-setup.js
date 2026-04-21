// =============================================
// MONGODB SETUP SCRIPT FOR GROUP FEATURE
// =============================================
// Cách dùng:
// cd backend && node mongodb-setup.js
// =============================================

const mongoose = require('mongoose');

const MONGODB_URI =
  process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/smartspender';

async function setupCollections() {
  try {
    console.log('📡 Connecting to MongoDB...');
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    const db = mongoose.connection.db;

    console.log('🔧 SETTING UP GROUP FEATURE COLLECTIONS...\n');

    // ===== STEP 1: CREATE COLLECTION - groups =====
    console.log('1️⃣ Creating collection: groups');

    try {
      await db.createCollection('groups', {
        validator: {
          $jsonSchema: {
            bsonType: 'object',
            required: ['name', 'createdBy'],
            properties: {
              _id: { bsonType: 'objectId' },
              name: { bsonType: 'string', minLength: 3, maxLength: 50 },
              description: { bsonType: 'string', maxLength: 200 },
              createdBy: { bsonType: 'objectId' },
              createdAt: { bsonType: 'date' },
              updatedAt: { bsonType: 'date' },
            },
          },
        },
      });
    } catch (err) {
      if (err.code !== 48) throw err; // 48 = namespace exists
    }

    await db.collection('groups').createIndex({ createdBy: 1 });
    await db.collection('groups').createIndex({ createdAt: -1 });
    console.log('✅ Collection "groups" created with indexes\n');

    // ===== STEP 2: CREATE COLLECTION - group_members =====
    console.log('2️⃣ Creating collection: group_members');

    try {
      await db.createCollection('group_members', {
        validator: {
          $jsonSchema: {
            bsonType: 'object',
            required: ['groupId', 'userId', 'role'],
            properties: {
              _id: { bsonType: 'objectId' },
              groupId: { bsonType: 'objectId' },
              userId: { bsonType: 'objectId' },
              role: { enum: ['admin', 'member', 'viewer'] },
              joinedAt: { bsonType: 'date' },
            },
          },
        },
      });
    } catch (err) {
      if (err.code !== 48) throw err;
    }

    await db.collection('group_members').createIndex({ groupId: 1 });
    await db.collection('group_members').createIndex({ userId: 1 });
    await db
      .collection('group_members')
      .createIndex({ groupId: 1, userId: 1 }, { unique: true });
    await db
      .collection('group_members')
      .createIndex({ groupId: 1, joinedAt: -1 });
    console.log('✅ Collection "group_members" created with indexes\n');

    // ===== STEP 3: CREATE COLLECTION - group_wallets =====
    console.log('3️⃣ Creating collection: group_wallets');

    try {
      await db.createCollection('group_wallets', {
        validator: {
          $jsonSchema: {
            bsonType: 'object',
            required: ['groupId', 'name', 'currency'],
            properties: {
              _id: { bsonType: 'objectId' },
              groupId: { bsonType: 'objectId' },
              name: { bsonType: 'string', minLength: 3, maxLength: 50 },
              balance: { bsonType: 'number' },
              currency: { enum: ['VND', 'USD', 'EUR'] },
              createdAt: { bsonType: 'date' },
              updatedAt: { bsonType: 'date' },
            },
          },
        },
      });
    } catch (err) {
      if (err.code !== 48) throw err;
    }

    await db.collection('group_wallets').createIndex({ groupId: 1 });
    await db.collection('group_wallets').createIndex({ groupId: 1, name: 1 });
    await db
      .collection('group_wallets')
      .createIndex({ groupId: 1, createdAt: -1 });
    console.log('✅ Collection "group_wallets" created with indexes\n');

    // ===== STEP 4: ADD groupId FIELD TO transactions =====
    console.log('4️⃣ Updating collection: transactions (adding groupId field)');

    await db
      .collection('transactions')
      .updateMany({}, { $set: { groupId: null } }, { upsert: false });
    await db.collection('transactions').createIndex({ groupId: 1 });
    await db
      .collection('transactions')
      .createIndex({ groupId: 1, walletId: 1 });
    console.log('✅ Collection "transactions" updated\n');

    // ===== VERIFICATION =====
    console.log('📊 VERIFICATION:\n');

    const collections = ['groups', 'group_members', 'group_wallets'];
    for (const col of collections) {
      const count = await db.collection(col).countDocuments();
      console.log(`   ${col}: ${count} documents`);
    }

    console.log('\n✅ MONGODB SETUP COMPLETED!\n');
    console.log('📝 Next step: Run seeding script');
    console.log('   Command: node backend/seeds/group-seed.js\n');

    await mongoose.disconnect();
    console.log('✅ MongoDB connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    await mongoose.disconnect();
    process.exit(1);
  }
}

setupCollections();
