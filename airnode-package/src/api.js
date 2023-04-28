// Functionalities related with the API setup for the airnode deployment.

import { randomBytes } from 'crypto';

/**
 * Generates a random key of the specified size.
 * @param {number} [size=32] - The size of the key to generate 
 */
function generateKey(
  size = 32
) {
  const buffer = randomBytes(size);
  const key = buffer.toString('base64');
  console.log(key);
};

generateKey();
