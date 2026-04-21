# 📤 GIT COMMIT & PUSH GUIDE

**Objective:** Commit Phase 1 files to GitHub  
**Branch:** `docs/phase1-design`  
**Commit Message:** "docs: Phase 1 complete"

---

## ✅ PRE-COMMIT VERIFICATION

Before committing, verify:

```bash
# 1. Check git status
git status

# Should show:
# ✅ New files: docs/*.md, mongodb-*.js, seeds/group-seed.js, postman/*.json
# 🔴 Should NOT have: node_modules, .env, temp files

# 2. Check branch name
git branch
# Should be on: docs/phase1-design

# 3. Verify files exist
ls backend/docs/
ls backend/seeds/
ls backend/postman/
ls backend/*.js
```

---

## 🚀 COMMIT STEPS (Copy-Paste)

### **Step 1: Stage files**

```bash
cd backend

git add docs/GROUP_API_SPECIFICATION.md
git add docs/GROUP_DATABASE_SCHEMA.md
git add docs/PHASE1_CHECKLIST.md
git add docs/PHASE1_FINAL_CHECKLIST.md
git add docs/QUICK_START_EXECUTION.md
git add docs/TEAM_KICKOFF.md
git add docs/README_PHASE1.md

git add mongodb-setup.js
git add mongodb-verify.js

git add seeds/group-seed.js

git add postman/group-api.postman_collection.json
git add postman/SmartSpender-GroupAPI.postman_environment.json
```

### **OR: Stage all at once**

```bash
cd backend
git add docs/ seeds/ postman/ mongodb-*.js
```

---

### **Step 2: Verify staging**

```bash
git status

# Should show:
# On branch docs/phase1-design
#
# Changes to be committed:
#   new file:   docs/GROUP_API_SPECIFICATION.md
#   new file:   docs/GROUP_DATABASE_SCHEMA.md
#   ... (all files green)
```

---

### **Step 3: Commit**

```bash
git commit -m "docs: Phase 1 complete - API spec, DB schema, seeding, Postman collection ready"

# OR more detailed:
git commit -m "docs: Phase 1 design complete

- Add GROUP_API_SPECIFICATION.md (20 endpoints fully documented)
- Add GROUP_DATABASE_SCHEMA.md (3 collections with indexes)
- Add seeding script: group-seed.js (creates mock data)
- Add Postman collection: group-api.postman_collection.json (20 requests)
- Add Postman environment: SmartSpender-GroupAPI.postman_environment.json
- Add MongoDB setup script: mongodb-setup.js
- Add MongoDB verify script: mongodb-verify.js
- Add execution guides: PHASE1_FINAL_CHECKLIST.md, QUICK_START_EXECUTION.md, TEAM_KICKOFF.md
- Add README: README_PHASE1.md

Ready for Phase 2 (team coding 3-5 April)
Team assignment: Nam (Groups), Ngoc Anh (Members), Chuc (Wallets), Xuan (Transactions)"
```

---

### **Step 4: Verify commit**

```bash
git log --oneline -3

# Should show your new commit at top:
# abc1234 docs: Phase 1 complete - API spec, DB schema...
```

---

### **Step 5: Push to GitHub**

```bash
git push origin docs/phase1-design

# Should get response:
# Enumerating objects: XX, done.
# Counting objects: XX% (XX/XX), done.
# Writing objects: 100% (XX/XX), XXX KB | XXX KB/s, done.
# Total XX (delta XX), reused 0 (delta 0), pack-reused 0 (remote)
# remote: Resolving deltas: 100% (XX/XX), done.
# To github.com:your-repo/smartspender.git
#  * [new branch]      docs/phase1-design -> docs/phase1-design
```

---

### **Step 6: Verify on GitHub**

```bash
# Open browser and navigate to:
# https://github.com/yourname/smartspender

# Should see:
# - Branch selector shows "docs/phase1-design"
# - Files visible in backend/docs/, backend/seeds/, etc.
# - Commit message visible in history
```

---

## ✅ FINAL VERIFICATION

Confirm everything is pushed:

```bash
# Check remote branch exists
git branch -r
# Should show: origin/docs/phase1-design

# Check latest commit
git log -1 --oneline origin/docs/phase1-design
# Should show your commit message

# Compare local vs remote
git diff origin/docs/phase1-design
# Should be empty (local = remote)
```

---

## 📋 COMMIT CHECKLIST

- [ ] All docs files added (7 files)
- [ ] MongoDB scripts added (2 files)
- [ ] Seeding script added (1 file)
- [ ] Postman files added (2 files)
- [ ] `git status` shows all files staged
- [ ] Commit message meaningful + detailed
- [ ] `git push` successful
- [ ] Remote branch visible on GitHub
- [ ] Files visible on GitHub web interface

---

## 🎯 WHAT TO COMMIT

✅ **DO COMMIT:**

```
✅ backend/docs/*.md (all markdown files)
✅ backend/mongodb-setup.js
✅ backend/mongodb-verify.js
✅ backend/seeds/group-seed.js
✅ backend/postman/group-api.postman_collection.json
✅ backend/postman/SmartSpender-GroupAPI.postman_environment.json
```

❌ **DO NOT COMMIT:**

```
❌ node_modules/ (too large)
❌ .env (contains secrets)
❌ build/ (generated files)
❌ dist/ (generated files)
❌ .DS_Store (OS files)
❌ *.log (log files)
```

---

## 🔄 IF SOMETHING GOES WRONG

### **Problem: "Cannot push - branch doesn't exist"**

```bash
# Solution: Create branch locally first
git checkout -b docs/phase1-design
git push -u origin docs/phase1-design
```

### **Problem: "Changes rejected as they violate branch protection rules"**

```bash
# You don't have permission to push directly
# Solution: Create PR instead (GitHub web interface)
# Or: Ask admin to grant permission
```

### **Problem: "Merge conflict with main branch"**

```bash
# Solution: Pull latest main first
git fetch origin main
git merge origin/main
# Fix conflicts
git add .
git commit -m "Merge main into docs/phase1-design"
git push origin docs/phase1-design
```

### **Problem: "Forgot to add a file"**

```bash
# Solution: Add + amend commit
git add forgotten-file.js
git commit --amend --no-edit
git push origin docs/phase1-design -f
# Note: -f force push (only if you're alone on branch)
```

---

## 📞 SUCCESS SIGNAL

✅ **YOU'RE DONE** when:

```
✅ Local: git log shows your commit
✅ Remote: GitHub web shows new branch + files
✅ Team: Can see all files on GitHub
✅ Ready: "Merge to main" button available on GitHub
```

Then proceed to:

- [ ] Team Kickoff Meeting (Day 2, 15:00)
- [ ] Phase 2 Coding (Day 3-5)

---

**Time:** ~5-10 minutes  
**Difficulty:** Easy  
**Risk:** Low (new branch, can't break main)

Good luck! 🚀
