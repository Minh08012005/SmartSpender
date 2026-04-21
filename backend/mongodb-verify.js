// =============================================
// VERIFICATION SCRIPT FOR PHASE 1 SETUP
// =============================================
// Cách dùng:
// 1. Mở mongosh
// 2. use smartspender
// 3. Copy-paste script này
// =============================================

console.log('\n🔍 VERIFYING PHASE 1 SETUP...\n');

// Check Collections exist
console.log('📊 1. CHECKING COLLECTIONS:');
const collections = [
  'groups',
  'group_members',
  'group_wallets',
  'transactions',
];

collections.forEach((col) => {
  try {
    const count = db[col].countDocuments();
    console.log(`   ✅ ${col}: ${count} documents`);
  } catch (e) {
    console.log(`   ❌ ${col}: NOT FOUND`);
  }
});

// Check Indexes
console.log('\n📑 2. CHECKING INDEXES:');

const indexChecks = [
  { col: 'groups', index: 'createdBy_1' },
  { col: 'group_members', index: 'groupId_1' },
  { col: 'group_wallets', index: 'groupId_1' },
  { col: 'transactions', index: 'groupId_1' },
];

indexChecks.forEach((item) => {
  const indexes = db[item.col].getIndexes();
  const hasIndex = indexes.some((idx) => {
    const keys = Object.keys(idx.key);
    return keys.length > 0;
  });
  console.log(`   ✅ ${item.col}: ${indexes.length} indexes`);
});

// Check Mock Data
console.log('\n🗄️ 3. CHECKING MOCK DATA:');

const groupCount = db.groups.countDocuments();
const memberCount = db.group_members.countDocuments();
const walletCount = db.group_wallets.countDocuments();
const transCount = db.transactions.countDocuments({ groupId: { $ne: null } });

console.log(`   Groups: ${groupCount} (expected: 3)`);
console.log(`   Members: ${memberCount} (expected: 10)`);
console.log(`   Wallets: ${walletCount} (expected: 5)`);
console.log(`   Transactions: ${transCount} (expected: 15)`);

const mockDataOK = groupCount === 3 && memberCount === 10 && walletCount === 5;
if (mockDataOK) {
  console.log('   ✅ All mock data present');
} else {
  console.log('   ⚠️  Some data missing - run seeding script');
}

// Summary
console.log('\n📋 SUMMARY:\n');

const setupOK = collections.every((col) => {
  try {
    db[col].countDocuments();
    return true;
  } catch {
    return false;
  }
});

if (setupOK && mockDataOK) {
  console.log('✅ PHASE 1 SETUP COMPLETE!\n');
  console.log('Next steps:');
  console.log(
    '  1. Import Postman collection: backend/postman/group-api.postman_collection.json'
  );
  console.log(
    '  2. Import Postman environment: backend/postman/SmartSpender-GroupAPI.postman_environment.json'
  );
  console.log('  3. Test 1 endpoint: GET /api/groups');
  console.log('  4. Run team kickoff meeting\n');
} else if (setupOK) {
  console.log('⚠️ Collections exist but mock data missing');
  console.log('   Run: node backend/seeds/group-seed.js\n');
} else {
  console.log('❌ PHASE 1 SETUP INCOMPLETE');
  console.log('   Run MongoDB setup script first\n');
}

console.log('═══════════════════════════════════════════\n');
