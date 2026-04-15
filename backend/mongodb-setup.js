// =============================================
// MONGODB SETUP SCRIPT FOR GROUP FEATURE
// =============================================
// Cách dùng:
// 1. Mở mongosh hoặc MongoDB shell
// 2. Chạy: use smartspender
// 3. Copy-paste tất cả script này vào shell
// =============================================

console.log('🔧 SETTING UP GROUP FEATURE COLLECTIONS...\n');

// ===== STEP 1: CREATE COLLECTION - groups =====
console.log('1️⃣ Creating collection: groups');

db.createCollection('groups', {
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

db.groups.createIndex({ createdBy: 1 });
db.groups.createIndex({ createdAt: -1 });
console.log('✅ Collection "groups" created with indexes\n');

// ===== STEP 2: CREATE COLLECTION - group_members =====
console.log('2️⃣ Creating collection: group_members');

db.createCollection('group_members', {
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

db.group_members.createIndex({ groupId: 1 });
db.group_members.createIndex({ userId: 1 });
db.group_members.createIndex({ groupId: 1, userId: 1 }, { unique: true });
db.group_members.createIndex({ groupId: 1, joinedAt: -1 });
console.log('✅ Collection "group_members" created with indexes\n');

// ===== STEP 3: CREATE COLLECTION - group_wallets =====
console.log('3️⃣ Creating collection: group_wallets');

db.createCollection('group_wallets', {
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

db.group_wallets.createIndex({ groupId: 1 });
db.group_wallets.createIndex({ groupId: 1, name: 1 });
db.group_wallets.createIndex({ groupId: 1, createdAt: -1 });
console.log('✅ Collection "group_wallets" created with indexes\n');

// ===== STEP 4: ADD groupId FIELD TO transactions =====
console.log('4️⃣ Updating collection: transactions (adding groupId field)');

db.transactions.updateMany({}, { $set: { groupId: null } }, { upsert: false });

db.transactions.createIndex({ groupId: 1 });
db.transactions.createIndex({ groupId: 1, walletId: 1 });
console.log('✅ Collection "transactions" updated\n');

// ===== VERIFICATION =====
console.log('📊 VERIFICATION:\n');

const collections = ['groups', 'group_members', 'group_wallets'];
collections.forEach((col) => {
  const count = db[col].countDocuments();
  console.log(`   ${col}: ${count} documents`);
});

console.log('\n✅ MONGODB SETUP COMPLETED!\n');
console.log('📝 Next step: Run seeding script');
console.log('   Command: node backend/seeds/group-seed.js\n');
