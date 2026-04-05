import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import cors from 'cors';

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const corsHandler = cors({ origin: true });

// ============================================================================
// USER PROFILE MANAGEMENT
// ============================================================================

/**
 * Create or update user profile
 * POST /createUserProfile
 */
export const createUserProfile = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId, name, dateOfBirth, timeOfBirth, placeOfBirth, gender } = req.body;

      if (!userId || !name || !dateOfBirth) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const userProfile = {
        userId,
        name,
        dateOfBirth,
        timeOfBirth,
        placeOfBirth,
        gender,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      };

      await db.collection('users').doc(userId).set(userProfile);

      res.status(200).json({ 
        success: true, 
        message: 'User profile created successfully',
        userId 
      });
    } catch (error) {
      console.error('Error creating user profile:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Get user profile
 * GET /getUserProfile?userId=<userId>
 */
export const getUserProfile = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId } = req.query;

      if (!userId) {
        res.status(400).json({ error: 'userId is required' });
        return;
      }

      const userDoc = await db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        res.status(404).json({ error: 'User not found' });
        return;
      }

      res.status(200).json({
        success: true,
        data: userDoc.data()
      });
    } catch (error) {
      console.error('Error fetching user profile:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// ============================================================================
// LOTTERY HISTORY MANAGEMENT
// ============================================================================

/**
 * Save lottery play to history
 * POST /saveLotteryPlay
 */
export const saveLotteryPlay = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId, lotteryType, numbers, amount, date } = req.body;

      if (!userId || !lotteryType || !numbers) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const lotteryPlay = {
        userId,
        lotteryType,
        numbers: Array.isArray(numbers) ? numbers : [numbers],
        amount: amount || 0,
        date: date || new Date().toISOString(),
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };

      const docRef = await db.collection('lotteryHistory').add(lotteryPlay);

      res.status(200).json({
        success: true,
        message: 'Lottery play saved successfully',
        playId: docRef.id
      });
    } catch (error) {
      console.error('Error saving lottery play:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Get lottery history for a user
 * GET /getLotteryHistory?userId=<userId>&limit=50
 */
export const getLotteryHistory = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId, limit = '50' } = req.query;

      if (!userId) {
        res.status(400).json({ error: 'userId is required' });
        return;
      }

      const querySnapshot = await db
        .collection('lotteryHistory')
        .where('userId', '==', userId)
        .orderBy('createdAt', 'desc')
        .limit(parseInt(limit))
        .get();

      const history = [];
      querySnapshot.forEach((doc) => {
        history.push({
          id: doc.id,
          ...doc.data()
        });
      });

      res.status(200).json({
        success: true,
        data: history,
        count: history.length
      });
    } catch (error) {
      console.error('Error fetching lottery history:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// ============================================================================
// LUCKY NUMBERS TRACKING
// ============================================================================

/**
 * Save daily lucky numbers
 * POST /saveDailyLuckyNumbers
 */
export const saveDailyLuckyNumbers = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId, day, numbers, color, energyLevel, luckyTime } = req.body;

      if (!userId || !day || !numbers) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const luckyNumbers = {
        userId,
        day,
        numbers: Array.isArray(numbers) ? numbers : [numbers],
        color: color || 'gold',
        energyLevel: energyLevel || 'Medium',
        luckyTime: luckyTime || '12:00',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      };

      const docRef = await db.collection('luckyNumbers').add(luckyNumbers);

      res.status(200).json({
        success: true,
        message: 'Lucky numbers saved successfully',
        recordId: docRef.id
      });
    } catch (error) {
      console.error('Error saving lucky numbers:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

/**
 * Get lucky numbers for a user
 * GET /getLuckyNumbers?userId=<userId>&days=30
 */
export const getLuckyNumbers = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId, days = '30' } = req.query;

      if (!userId) {
        res.status(400).json({ error: 'userId is required' });
        return;
      }

      const daysAgo = new Date();
      daysAgo.setDate(daysAgo.getDate() - parseInt(days));

      const querySnapshot = await db
        .collection('luckyNumbers')
        .where('userId', '==', userId)
        .where('createdAt', '>=', daysAgo)
        .orderBy('createdAt', 'desc')
        .get();

      const numbers = [];
      querySnapshot.forEach((doc) => {
        numbers.push({
          id: doc.id,
          ...doc.data()
        });
      });

      res.status(200).json({
        success: true,
        data: numbers,
        count: numbers.length
      });
    } catch (error) {
      console.error('Error fetching lucky numbers:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// ============================================================================
// ANALYTICS & STATISTICS
// ============================================================================

/**
 * Get user statistics
 * GET /getUserStatistics?userId=<userId>
 */
export const getUserStatistics = functions.https.onRequest((req, res) => {
  corsHandler(req, res, async () => {
    if (req.method !== 'GET') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    try {
      const { userId } = req.query;

      if (!userId) {
        res.status(400).json({ error: 'userId is required' });
        return;
      }

      // Get total lottery plays
      const historySnapshot = await db
        .collection('lotteryHistory')
        .where('userId', '==', userId)
        .get();

      // Get lucky numbers count
      const luckyNumbersSnapshot = await db
        .collection('luckyNumbers')
        .where('userId', '==', userId)
        .get();

      // Get most used lottery type
      const historyData = [];
      historySnapshot.forEach((doc) => {
        historyData.push(doc.data());
      });

      const lotteryTypeCounts = {};
      historyData.forEach((play) => {
        lotteryTypeCounts[play.lotteryType] = (lotteryTypeCounts[play.lotteryType] || 0) + 1;
      });

      const mostUsedType = Object.entries(lotteryTypeCounts).reduce(
        (max, [type, count]) => (count > (max[1] || 0) ? [type, count] : max),
        []
      );

      res.status(200).json({
        success: true,
        data: {
          totalLotteryPlays: historySnapshot.size,
          totalLuckyNumbersGenerated: luckyNumbersSnapshot.size,
          mostUsedLotteryType: mostUsedType[0] || 'None',
          lotteryTypeCounts
        }
      });
    } catch (error) {
      console.error('Error fetching user statistics:', error);
      res.status(500).json({ error: error.message });
    }
  });
});

// ============================================================================
// SCHEDULED FUNCTIONS
// ============================================================================

/**
 * Scheduled function to clean up old records (runs daily at 2 AM)
 */
export const cleanupOldRecords = functions
  .pubsub
  .schedule('0 2 * * *')
  .timeZone('UTC')
  .onRun(async () => {
    try {
      // Keep records for 1 year
      const oneYearAgo = new Date();
      oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

      const querySnapshot = await db
        .collection('lotteryHistory')
        .where('createdAt', '<', oneYearAgo)
        .get();

      const batch = db.batch();
      let count = 0;

      querySnapshot.forEach((doc) => {
        batch.delete(doc.ref);
        count++;
      });

      if (count > 0) {
        await batch.commit();
        console.log(`Cleanup: Deleted ${count} old lottery history records`);
      }

      return { success: true, deletedCount: count };
    } catch (error) {
      console.error('Error during cleanup:', error);
      return { success: false, error: error.message };
    }
  });
