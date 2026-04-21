-- =====================================================
-- BookBazaar Complete Database Setup
-- =====================================================
-- This file creates the complete database with all tables and sample data
-- Simply import this file into MySQL to set up everything

-- Create and use database
DROP DATABASE IF EXISTS bookbazaar;
CREATE DATABASE bookbazaar;
USE bookbazaar;

-- =====================================================
-- 1. USERS TABLE
-- =====================================================
CREATE TABLE Users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('user', 'admin') DEFAULT 'user',
  isActive BOOLEAN DEFAULT true,
  avatar VARCHAR(255),
  phone VARCHAR(255),
  address TEXT,
  isVerified BOOLEAN DEFAULT false,
  resetPasswordToken VARCHAR(255),
  resetPasswordExpire DATETIME,
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_isActive (isActive)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 2. BOOKS TABLE
-- =====================================================
CREATE TABLE Books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  author VARCHAR(255) NOT NULL,
  isbn VARCHAR(255) UNIQUE,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  category VARCHAR(255) NOT NULL,
  `condition` ENUM('new', 'like-new', 'good', 'fair') DEFAULT 'good',
  stock INT DEFAULT 1,
  image VARCHAR(255),
  images JSON,
  publisher VARCHAR(255),
  publishedDate DATETIME,
  language VARCHAR(255) DEFAULT 'English',
  pages INT,
  rating DECIMAL(2, 1) DEFAULT 0,
  numReviews INT DEFAULT 0,
  isFeatured BOOLEAN DEFAULT false,
  sellerId INT NOT NULL,
  approvalStatus ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  approvedBy INT,
  approvedAt DATETIME,
  rejectionReason TEXT,
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (sellerId) REFERENCES Users(id) ON DELETE CASCADE,
  FOREIGN KEY (approvedBy) REFERENCES Users(id),
  INDEX idx_sellerId (sellerId),
  INDEX idx_approvalStatus (approvalStatus),
  INDEX idx_category (category),
  INDEX idx_price (price),
  INDEX idx_title (title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 3. ORDERS TABLE
-- =====================================================
CREATE TABLE Orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  orderId VARCHAR(255) UNIQUE,
  userId INT NOT NULL,
  orderItems JSON NOT NULL,
  shippingAddress JSON NOT NULL,
  paymentMethod VARCHAR(255) NOT NULL,
  paymentStatus ENUM('pending', 'paid', 'failed', 'refunded') DEFAULT 'pending',
  paymentResult JSON,
  itemsPrice DECIMAL(10, 2) NOT NULL,
  taxPrice DECIMAL(10, 2) DEFAULT 0,
  shippingPrice DECIMAL(10, 2) DEFAULT 0,
  totalPrice DECIMAL(10, 2) NOT NULL,
  isPaid BOOLEAN DEFAULT false,
  paidAt DATETIME,
  isDelivered BOOLEAN DEFAULT false,
  deliveredAt DATETIME,
  status ENUM('pending', 'confirmed', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  trackingNumber VARCHAR(255),
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE,
  INDEX idx_userId (userId),
  INDEX idx_orderId (orderId),
  INDEX idx_status (status),
  INDEX idx_paymentStatus (paymentStatus),
  INDEX idx_createdAt (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 4. REVIEWS TABLE
-- =====================================================
CREATE TABLE Reviews (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  bookId INT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  isVerified BOOLEAN DEFAULT false,
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE,
  FOREIGN KEY (bookId) REFERENCES Books(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_book (userId, bookId),
  INDEX idx_bookId (bookId),
  INDEX idx_userId (userId),
  INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 5. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE Notifications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  userId INT NOT NULL,
  type ENUM('order', 'review', 'system', 'promotion') NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  isRead BOOLEAN DEFAULT false,
  link VARCHAR(255),
  createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE,
  INDEX idx_userId (userId),
  INDEX idx_isRead (isRead),
  INDEX idx_createdAt (createdAt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 6. ADMIN LOGS TABLE
-- =====================================================
CREATE TABLE AdminLogs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  adminId INT NOT NULL,
  action ENUM('user_update', 'user_deactivate', 'user_activate', 'book_approve', 'book_reject', 'order_update', 'order_cancel') NOT NULL,
  resourceType ENUM('user', 'book', 'order') NOT NULL,
  resourceId VARCHAR(255) NOT NULL,
  details JSON,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (adminId) REFERENCES Users(id) ON DELETE CASCADE,
  INDEX idx_adminId (adminId),
  INDEX idx_action (action),
  INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- 7. INSERT SAMPLE DATA
-- =====================================================

-- Insert Users (including admin)
-- Note: Passwords are hashed with bcrypt
-- admin123 = $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- password123 = $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
INSERT INTO Users (name, email, password, role, isActive, createdAt, updatedAt) VALUES
('Admin User', 'admin@bookbazaar.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', true, NOW(), NOW()),
('Harsh Jaiswal', 'kittu123@gmail.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', true, NOW(), NOW()),
('Shiva Kumar', 'shiva123@gmail.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', true, NOW(), NOW()),
('Riya Sharma', 'riya123@gmail.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', true, NOW(), NOW()),
('John Doe', 'john@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user', true, NOW(), NOW());

-- Insert Sample Books
INSERT INTO Books (title, author, description, price, category, `condition`, stock, sellerId, approvalStatus, createdAt, updatedAt) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', 'A classic American novel about the Jazz Age', 299.99, 'Fiction', 'good', 5, 2, 'approved', NOW(), NOW()),
('To Kill a Mockingbird', 'Harper Lee', 'A gripping tale of racial injustice and childhood innocence', 349.99, 'Fiction', 'like-new', 3, 3, 'approved', NOW(), NOW()),
('1984', 'George Orwell', 'A dystopian social science fiction novel', 279.99, 'Fiction', 'good', 7, 4, 'approved', NOW(), NOW()),
('Pride and Prejudice', 'Jane Austen', 'A romantic novel of manners', 259.99, 'Romance', 'good', 4, 5, 'approved', NOW(), NOW()),
('The Catcher in the Rye', 'J.D. Salinger', 'A controversial novel about teenage rebellion', 289.99, 'Fiction', 'fair', 2, 2, 'pending', NOW(), NOW()),
('Harry Potter and the Philosopher\'s Stone', 'J.K. Rowling', 'The first book in the Harry Potter series', 399.99, 'Fantasy', 'new', 10, 3, 'approved', NOW(), NOW()),
('The Lord of the Rings', 'J.R.R. Tolkien', 'An epic high fantasy novel', 599.99, 'Fantasy', 'like-new', 3, 4, 'approved', NOW(), NOW()),
('Dune', 'Frank Herbert', 'A science fiction masterpiece', 449.99, 'Science Fiction', 'good', 6, 5, 'approved', NOW(), NOW());

-- Insert Sample Orders
INSERT INTO Orders (orderId, userId, orderItems, shippingAddress, paymentMethod, paymentStatus, itemsPrice, taxPrice, shippingPrice, totalPrice, status, createdAt, updatedAt) VALUES
('ORD-2026-001', 2, '[{"bookId":1,"title":"The Great Gatsby","author":"F. Scott Fitzgerald","price":299.99,"quantity":1}]', '{"fullName":"Harsh Jaiswal","address":"123 Main St","city":"Mumbai","state":"Maharashtra","postalCode":"400001","country":"India"}', 'COD', 'pending', 299.99, 0, 50, 349.99, 'pending', NOW(), NOW()),
('ORD-2026-002', 3, '[{"bookId":2,"title":"To Kill a Mockingbird","author":"Harper Lee","price":349.99,"quantity":1},{"bookId":3,"title":"1984","author":"George Orwell","price":279.99,"quantity":1}]', '{"fullName":"Shiva Kumar","address":"456 Park Ave","city":"Delhi","state":"Delhi","postalCode":"110001","country":"India"}', 'UPI', 'paid', 629.98, 31.50, 50, 711.48, 'confirmed', NOW(), NOW()),
('ORD-2026-003', 4, '[{"bookId":6,"title":"Harry Potter and the Philosopher\'s Stone","author":"J.K. Rowling","price":399.99,"quantity":2}]', '{"fullName":"Riya Sharma","address":"789 Oak St","city":"Bangalore","state":"Karnataka","postalCode":"560001","country":"India"}', 'Credit Card', 'paid', 799.98, 40.00, 50, 889.98, 'shipped', NOW(), NOW()),
('ORD-2026-004', 5, '[{"bookId":7,"title":"The Lord of the Rings","author":"J.R.R. Tolkien","price":599.99,"quantity":1}]', '{"fullName":"John Doe","address":"321 Pine St","city":"Chennai","state":"Tamil Nadu","postalCode":"600001","country":"India"}', 'COD', 'pending', 599.99, 30.00, 50, 679.99, 'delivered', NOW(), NOW());

-- Insert Sample Reviews
INSERT INTO Reviews (userId, bookId, rating, comment, createdAt, updatedAt) VALUES
(2, 1, 5, 'Excellent book! A true classic that everyone should read.', NOW(), NOW()),
(3, 2, 4, 'Very thought-provoking. Harper Lee\'s writing is beautiful.', NOW(), NOW()),
(4, 6, 5, 'Amazing start to the Harry Potter series. My kids love it!', NOW(), NOW()),
(5, 7, 5, 'Epic fantasy at its finest. Tolkien is a master storyteller.', NOW(), NOW()),
(2, 3, 4, 'Dystopian and disturbing, but incredibly well-written.', NOW(), NOW());

-- Insert Sample Notifications
INSERT INTO Notifications (userId, type, title, message, isRead, createdAt, updatedAt) VALUES
(2, 'order', 'Order Confirmed', 'Your order ORD-2026-001 has been confirmed and is being processed.', false, NOW(), NOW()),
(3, 'order', 'Order Shipped', 'Your order ORD-2026-002 has been shipped and is on its way.', true, NOW(), NOW()),
(4, 'order', 'Order Delivered', 'Your order ORD-2026-003 has been delivered successfully.', false, NOW(), NOW()),
(2, 'system', 'Welcome to BookBazaar', 'Thank you for joining BookBazaar! Start exploring our collection.', true, NOW(), NOW()),
(5, 'promotion', 'Special Offer', 'Get 20% off on your next purchase. Use code SAVE20', false, NOW(), NOW());

-- Insert Sample Admin Logs
INSERT INTO AdminLogs (adminId, action, resourceType, resourceId, details, timestamp) VALUES
(1, 'book_approve', 'book', '1', '{"bookTitle":"The Great Gatsby","reason":"Quality content approved"}', NOW()),
(1, 'book_approve', 'book', '2', '{"bookTitle":"To Kill a Mockingbird","reason":"Classic literature approved"}', NOW()),
(1, 'order_update', 'order', 'ORD-2026-002', '{"oldStatus":"pending","newStatus":"confirmed"}', NOW()),
(1, 'user_activate', 'user', '2', '{"userName":"Harsh Jaiswal","reason":"Account verification completed"}', NOW());

-- =====================================================
-- 8. UPDATE BOOK RATINGS BASED ON REVIEWS
-- =====================================================
UPDATE Books b SET 
  rating = (
    SELECT AVG(r.rating) 
    FROM Reviews r 
    WHERE r.bookId = b.id
  ),
  numReviews = (
    SELECT COUNT(*) 
    FROM Reviews r 
    WHERE r.bookId = b.id
  )
WHERE b.id IN (SELECT DISTINCT bookId FROM Reviews);

-- =====================================================
-- 9. VERIFICATION QUERIES
-- =====================================================
-- These queries will show you the data that was inserted

SELECT 'DATABASE SETUP COMPLETED SUCCESSFULLY!' as Status;

SELECT 'USERS' as TableName, COUNT(*) as RecordCount FROM Users
UNION ALL
SELECT 'BOOKS', COUNT(*) FROM Books
UNION ALL
SELECT 'ORDERS', COUNT(*) FROM Orders
UNION ALL
SELECT 'REVIEWS', COUNT(*) FROM Reviews
UNION ALL
SELECT 'NOTIFICATIONS', COUNT(*) FROM Notifications
UNION ALL
SELECT 'ADMIN LOGS', COUNT(*) FROM AdminLogs;

-- Show admin user
SELECT 'ADMIN USER CREATED:' as Info;
SELECT id, name, email, role, isActive FROM Users WHERE role = 'admin';

-- Show approved books
SELECT 'APPROVED BOOKS:' as Info;
SELECT id, title, author, price, category, rating FROM Books WHERE approvalStatus = 'approved' LIMIT 5;

-- Show recent orders
SELECT 'RECENT ORDERS:' as Info;
SELECT o.orderId, u.name as customer, o.totalPrice, o.status, o.createdAt 
FROM Orders o 
JOIN Users u ON o.userId = u.id 
ORDER BY o.createdAt DESC LIMIT 5;

-- Show order statistics for admin dashboard
SELECT 'ORDER STATISTICS:' as Info;
SELECT 
  status,
  COUNT(*) as count,
  SUM(totalPrice) as total_amount
FROM Orders 
GROUP BY status;

SELECT 'SETUP COMPLETE - YOU CAN NOW START YOUR APPLICATION!' as FinalMessage;

-- =====================================================
-- END OF FILE
-- =====================================================