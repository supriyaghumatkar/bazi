-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 25, 2018 at 11:13 AM
-- Server version: 10.1.25-MariaDB
-- PHP Version: 5.6.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `recpro_feautre_acl`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `debug_msg` (`text` VARCHAR(255), `msg` VARCHAR(255))  BEGIN
	select concat(text, " ** ", msg) AS '** DEBUG:';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_add_node` (IN `p_parent` INT, IN `p_parent_user_id` INT, IN `p_user_id` INT)  proc: BEGIN
        DECLARE e_user_id_already_exists CONDITION FOR SQLSTATE '45000';
    DECLARE e_user_id_is_empty CONDITION FOR SQLSTATE '45000';
    DECLARE e_no_parent CONDITION FOR SQLSTATE '45000';
    DECLARE e_parent_not_found  CONDITION FOR SQLSTATE '45000';
    DECLARE v_parent_found INT DEFAULT 0;
    DECLARE v_found_user_id INT DEFAULT NULL;
    DECLARE v_parent_lft INT DEFAULT NULL;
    DECLARE v_parent_rht INT DEFAULT NULL;
    DECLARE v_parent_lvl MEDIUMINT DEFAULT NULL;
    DECLARE v_new_id INT DEFAULT NULL;

        IF ( p_parent IS NULL) THEN
        SIGNAL e_no_parent
            SET MESSAGE_TEXT = 'The id of the parent node cannot be empty.';
        LEAVE proc;
    END IF;
    SELECT id, lft, rht, lvl INTO v_parent_found, v_parent_lft, v_parent_rht, v_parent_lvl
    FROM users_reporting
    WHERE id = p_parent;

    IF ( v_parent_found IS NULL) THEN
        SIGNAL e_parent_not_found
            SET MESSAGE_TEXT = 'The id of the parent does not exists.';
        LEAVE proc;
    END IF;

        IF ( p_user_id IS NULL) OR ( p_user_id = '') THEN
        SIGNAL e_user_id_already_exists
            SET MESSAGE_TEXT = 'The id of the node cannot be empty.';
        LEAVE proc;
    END IF;

        SELECT 1
        INTO v_found_user_id
        FROM users_reporting
        WHERE lft >= v_parent_lft
        AND lft <  v_parent_rht
        AND lvl =  v_parent_lvl + 1
        AND user_id LIKE BINARY p_user_id ;

    IF v_found_user_id <> 0 THEN
        SIGNAL e_user_id_already_exists
            SET MESSAGE_TEXT = 'A node whith the exact same user_id already exists in this branch';
            LEAVE proc;
    END IF;

        START TRANSACTION;
                UPDATE users_reporting
        SET lft = CASE WHEN lft >  v_parent_rht THEN lft + 2 ELSE lft END
            ,rht = CASE WHEN rht >= v_parent_rht THEN rht + 2 ELSE rht END
        WHERE rht >= v_parent_rht;
                INSERT INTO users_reporting (parent_user_id, user_id, lft, rht, lvl)
        VALUES ( p_parent_user_id, p_user_id, v_parent_rht, v_parent_rht + 1, v_parent_lvl + 1);

        SELECT LAST_INSERT_ID() INTO v_new_id;
    COMMIT;

        SELECT v_new_id AS id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_add_root` ()  proc: BEGIN
        DECLARE e_table_not_empty CONDITION FOR SQLSTATE '45000';
    DECLARE v_found INT DEFAULT 0;

        SELECT COUNT(1) INTO v_found FROM users_reporting;
    IF v_found <> 0 THEN
        SIGNAL e_table_not_empty
            SET MESSAGE_TEXT = 'The table should be empty before adding a root node.';
        LEAVE proc;
    END IF;

        INSERT INTO users_reporting (user_id, lft, rht, lvl)
    VALUES (NULL, 1 , 2, 0);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_get_all` (IN `p_depth` TINYINT, IN `p_indent` VARCHAR(20))  proc: BEGIN
    CALL users_reporting_get_branch(1, p_depth, p_indent);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_get_branch` (IN `p_id` INT, IN `p_depth` TINYINT, IN `p_indent` VARCHAR(20))  proc: BEGIN
        DECLARE e_no_id CONDITION FOR SQLSTATE '45000';
    DECLARE e_id_not_found  CONDITION FOR SQLSTATE '45000';
    DECLARE v_node_found INT DEFAULT NULL;
    DECLARE v_node_lft INT DEFAULT NULL;
    DECLARE v_node_rht INT DEFAULT NULL;
    DECLARE v_node_lvl MEDIUMINT DEFAULT NULL;
    DECLARE v_indent VARCHAR(20) DEFAULT NULL;
    DECLARE v_depth TINYINT DEFAULT 127;

        IF ( p_id IS NULL) THEN
        SIGNAL e_no_id
            SET MESSAGE_TEXT = 'The id cannot be empty.';
        LEAVE proc;
    END IF;
    SELECT id, lft , rht ,lvl INTO v_node_found, v_node_lft, v_node_rht, v_node_lvl
    FROM users_reporting
    WHERE id = p_id;

    IF ( v_node_found IS NULL) THEN
        SIGNAL e_id_not_found
            SET MESSAGE_TEXT = 'The id does not exists.';
        LEAVE proc;
    END IF;

        SET v_indent := COALESCE( p_indent, '');
    SET v_depth := COALESCE( p_depth, v_depth);

        SELECT id
        , CONCAT(REPEAT( v_indent, (lvl - v_node_lvl) ), user_id) AS user_id
        , lvl
        , FORMAT((((rht - lft) -1) / 2),0) AS cnt_children
        , CASE WHEN rht - lft > 1 THEN 1 ELSE 0 END AS is_branch
    FROM users_reporting
    WHERE lft >= v_node_lft
    AND lft < v_node_rht
    AND lvl <= v_node_lvl + v_depth
    ORDER BY lft;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_get_parents` (IN `p_id` INT, IN `p_indent` VARCHAR(20))  proc: BEGIN
        DECLARE e_no_id CONDITION FOR SQLSTATE '45000';
    DECLARE e_id_not_found  CONDITION FOR SQLSTATE '45000';
    DECLARE v_node_found INT DEFAULT NULL;
    DECLARE v_node_lft INT DEFAULT NULL;
    DECLARE v_indent VARCHAR(20) DEFAULT NULL;

        IF (p_id IS NULL) THEN
        SIGNAL e_no_id
            SET MESSAGE_TEXT = 'The id cannot be empty.';
        LEAVE proc;
    END IF;
    SELECT id, lft INTO v_node_found, v_node_lft
        FROM users_reporting
        WHERE id = p_id;

    IF ( v_node_found IS NULL) THEN
        SIGNAL e_id_not_found
            SET MESSAGE_TEXT = 'The id does not exists.';
        LEAVE proc;
    END IF;

        SET v_indent := COALESCE( p_indent, '');

        SELECT a.id
            , a.user_id
            , a.lvl
        FROM users_reporting a, users_reporting b
        WHERE b.id = p_id
        AND a.id <> p_id
        AND b.lft BETWEEN a.lft AND a.rht
            ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_reporting_move_node` (IN `p_id` INT, IN `n_parent_user_id` INT, IN `n_id` INT)  proc: BEGIN
		SET @p_id = p_id; 	SET @parent_user_id = n_parent_user_id; 	SET @n_id = n_id; 
		SELECT rht, lft, rht-lft+1, lvl INTO @dir_rht, @dir_lft, @dir_size, @dir_lvl FROM users_reporting WHERE id = @p_id;

		UPDATE users_reporting SET lft = 0-lft, rht = 0-rht WHERE lft BETWEEN @dir_lft AND @dir_rht;

		UPDATE users_reporting SET rht = rht-@dir_size WHERE rht > @dir_rht;
	UPDATE users_reporting SET lft = lft-@dir_size WHERE lft > @dir_rht;

		SELECT lft, lvl, user_id INTO @target_lft, @target_lvl, @target_user_id FROM users_reporting WHERE id = @n_id;

		UPDATE users_reporting SET rht = rht+@dir_size WHERE rht >= @target_lft;
	UPDATE users_reporting SET lft = lft+@dir_size WHERE lft > @target_lft;

		UPDATE users_reporting 
    SET
	   lft = 0 - lft - (@dir_lft - @target_lft - 1), 	   rht = 0 - rht - (@dir_lft - @target_lft - 1), 
	   lvl = lvl - (@dir_lvl - @target_lvl) + 1
	WHERE lft < 0; 
        UPDATE users_reporting SET parent_user_id = @parent_user_id WHERE id = @p_id;

    SELECT n_id AS id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin_user`
--

CREATE TABLE `admin_user` (
  `id` int(255) NOT NULL,
  `admin_id` int(255) NOT NULL,
  `user_id` int(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin_user`
--

INSERT INTO `admin_user` (`id`, `admin_id`, `user_id`) VALUES
(18, 58, 62),
(23, 58, 73),
(24, 74, 78),
(25, 74, 79),
(26, 58, 80),
(34, 58, 93),
(39, 58, 94),
(49, 58, 119),
(50, 117, 125),
(51, 117, 126),
(52, 117, 127),
(53, 117, 128),
(54, 118, 129),
(55, 117, 130),
(56, 117, 131),
(57, 117, 132),
(61, 141, 142),
(62, 141, 143),
(63, 141, 144),
(64, 117, 145),
(65, 118, 146),
(66, 123, 149),
(67, 123, 150),
(70, 153, 161),
(72, 164, 165),
(73, 156, 166),
(74, 156, 167),
(78, 171, 180),
(79, 171, 181),
(80, 177, 182),
(81, 171, 184),
(82, 171, 185),
(83, 133, 187),
(109, 148, 224),
(110, 226, 228),
(111, 226, 229),
(112, 120, 230),
(113, 120, 231),
(114, 120, 232),
(165, 148, 287),
(166, 183, 288),
(167, 183, 289),
(168, 58, 290),
(176, 153, 299),
(177, 300, 301),
(178, 300, 302),
(179, 300, 303),
(180, 300, 304),
(181, 300, 305),
(185, 220, 312),
(187, 300, 318),
(188, 300, 319),
(189, 300, 320),
(190, 300, 321),
(191, 221, 324),
(192, 221, 325),
(193, 326, 327),
(194, 326, 328),
(195, 326, 329),
(196, 326, 330),
(197, 326, 331),
(198, 326, 332),
(207, 58, 343),
(208, 222, 344),
(209, 222, 345),
(210, 222, 346),
(212, 154, 349),
(213, 326, 350),
(215, 124, 355),
(217, 124, 362),
(218, 359, 363),
(219, 359, 364),
(227, 384, 386),
(228, 388, 389),
(229, 388, 390),
(230, 369, 391),
(231, 369, 392),
(232, 369, 393),
(233, 369, 394),
(234, 369, 395),
(236, 74, 401),
(237, 169, 405),
(238, 169, 406),
(241, 404, 409),
(242, 404, 410),
(243, 298, 413),
(244, 298, 414),
(245, 384, 416),
(247, 384, 418),
(248, 397, 419),
(249, 171, 422),
(250, 171, 423),
(251, 171, 425),
(252, 171, 426),
(253, 171, 427),
(254, 424, 428),
(255, 424, 429),
(256, 424, 430),
(257, 424, 431),
(258, 424, 432),
(259, 118, 434),
(260, 421, 435),
(261, 171, 439),
(262, 397, 440),
(263, 441, 442),
(264, 438, 443),
(269, 438, 448),
(270, 438, 449),
(271, 438, 450),
(272, 396, 451),
(273, 218, 452),
(274, 300, 454),
(275, 403, 456),
(276, 403, 457),
(278, 403, 459),
(279, 403, 460),
(280, 403, 461),
(281, 403, 462),
(282, 172, 463),
(283, 169, 464),
(284, 465, 467),
(285, 465, 468),
(286, 469, 470),
(287, 469, 471),
(288, 469, 472),
(289, 469, 474),
(290, 164, 475),
(291, 466, 476),
(292, 466, 477),
(293, 466, 478),
(294, 178, 479),
(295, 178, 480),
(296, 153, 481),
(299, 172, 486),
(300, 172, 487),
(301, 154, 488),
(302, 154, 489),
(303, 154, 490),
(304, 154, 491),
(305, 154, 492),
(306, 154, 493),
(307, 154, 494),
(308, 154, 495),
(309, 172, 498),
(311, 496, 500),
(312, 496, 501),
(313, 496, 502),
(314, 496, 503),
(315, 497, 504),
(316, 497, 505),
(317, 497, 506),
(318, 507, 511),
(319, 507, 512),
(320, 352, 514),
(321, 517, 519),
(322, 517, 520),
(324, 482, 527),
(325, 482, 528),
(326, 521, 532),
(327, 534, 535),
(328, 534, 536),
(329, 534, 537),
(330, 485, 538),
(331, 485, 539),
(332, 123, 544),
(333, 123, 545),
(334, 123, 546),
(335, 547, 548),
(336, 547, 549),
(337, 547, 550),
(338, 552, 553),
(339, 556, 557),
(340, 556, 558),
(341, 556, 559),
(342, 534, 560),
(343, 534, 561),
(344, 534, 562),
(345, 551, 563),
(346, 551, 564),
(347, 534, 566),
(348, 569, 571),
(349, 555, 572),
(350, 164, 573),
(351, 164, 574),
(352, 568, 575),
(353, 568, 576),
(354, 568, 577),
(355, 568, 578),
(356, 568, 579),
(357, 403, 580),
(358, 403, 581),
(359, 403, 582),
(360, 534, 586),
(361, 584, 587),
(362, 584, 588),
(363, 589, 591),
(364, 589, 592),
(365, 589, 593),
(366, 589, 594),
(367, 589, 595),
(368, 589, 596),
(369, 589, 597),
(370, 589, 598),
(371, 589, 599),
(372, 589, 600),
(373, 521, 601),
(374, 589, 602),
(375, 603, 604),
(376, 469, 612),
(377, 610, 613),
(378, 610, 614),
(379, 618, 617),
(380, 618, 621),
(381, 403, 619),
(382, 618, 626),
(383, 618, 627),
(384, 403, 629),
(385, 403, 630),
(386, 403, 631),
(387, 403, 632),
(388, 633, 634),
(389, 633, 635),
(390, 633, 639),
(391, 633, 643),
(392, 403, 644),
(393, 646, 647),
(394, 58, 648),
(395, 403, 649),
(396, 403, 650),
(397, 403, 651),
(398, 403, 652),
(399, 403, 653),
(400, 403, 654),
(401, 403, 660),
(402, 403, 661),
(403, 403, 662),
(404, 403, 663),
(405, 403, 664),
(406, 403, 665),
(407, 403, 666),
(408, 403, 667),
(409, 403, 668),
(410, 403, 669),
(411, 403, 671),
(412, 403, 672);

-- --------------------------------------------------------

--
-- Table structure for table `clients`
--

CREATE TABLE `clients` (
  `id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `default_hr` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `clients`
--

INSERT INTO `clients` (`id`, `organization_id`, `name`, `default_hr`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 1, 'Acme', NULL, 'active', '2018-03-01 09:35:46', 1, NULL, NULL),
(2, 2, 'Infosys', NULL, 'active', '2018-03-01 09:40:50', 2, NULL, NULL),
(3, 2, 'Symphony', NULL, 'active', '2018-03-01 09:40:56', 2, NULL, NULL),
(4, 3, 'Google123', NULL, 'active', '2018-03-01 09:41:24', 3, '2018-04-02 13:10:04', 3),
(5, 3, 'IBM', NULL, 'active', '2018-03-01 09:41:29', 3, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `clients_verticals`
--

CREATE TABLE `clients_verticals` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `clients_verticals`
--

INSERT INTO `clients_verticals` (`id`, `client_id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 2, 'Finance', 'active', '2018-03-01 09:45:53', 2, '2018-03-27 06:21:12', 2),
(2, 2, 'HR', 'active', '2018-03-01 09:46:21', 2, NULL, NULL),
(3, 2, 'IT', 'active', '2018-03-01 09:46:39', 2, NULL, NULL),
(4, 2, 'Manufacturing', 'active', '2018-03-01 09:47:00', 2, NULL, NULL),
(5, 2, 'Marketing', 'active', '2018-03-01 09:47:25', 2, NULL, NULL),
(6, 2, 'Sales', 'active', '2018-03-01 09:47:42', 2, NULL, NULL),
(7, 3, 'Finance', 'active', '2018-03-01 09:48:29', 2, NULL, NULL),
(8, 3, 'IT', 'active', '2018-03-01 09:48:47', 2, NULL, NULL),
(9, 3, 'Manufacturing', 'active', '2018-03-01 09:49:14', 2, NULL, NULL),
(10, 3, 'Marketing', 'active', '2018-03-01 09:49:26', 2, NULL, NULL),
(11, 3, 'Sales', 'active', '2018-03-01 09:50:42', 2, NULL, NULL),
(12, 4, 'Admin', 'active', '2018-03-01 09:58:16', 3, NULL, NULL),
(13, 4, 'Finance', 'active', '2018-03-01 09:58:51', 3, NULL, NULL),
(14, 4, 'HR', 'active', '2018-03-01 09:59:08', 3, NULL, NULL),
(15, 4, 'Manufacturing', 'active', '2018-03-01 09:59:25', 3, NULL, NULL),
(16, 4, 'Sales', 'active', '2018-03-01 09:59:38', 3, NULL, NULL),
(17, 5, 'Admin', 'active', '2018-03-01 10:00:21', 3, NULL, NULL),
(18, 5, 'Digital', 'active', '2018-03-01 10:00:30', 3, NULL, NULL),
(19, 5, 'Finance', 'active', '2018-03-01 10:01:15', 3, NULL, NULL),
(20, 5, 'HR', 'active', '2018-03-01 10:01:21', 3, NULL, NULL),
(21, 5, 'IT - Software', 'active', '2018-03-01 10:01:26', 3, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `clients_verticals_locations`
--

CREATE TABLE `clients_verticals_locations` (
  `id` int(11) NOT NULL,
  `client_vertical_id` int(11) NOT NULL,
  `client_location_id` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `clients_verticals_locations`
--

INSERT INTO `clients_verticals_locations` (`id`, `client_vertical_id`, `client_location_id`, `created`, `created_by`) VALUES
(1, 1, 110, '2018-03-01 09:45:53', 2),
(2, 1, 111, '2018-03-01 09:45:53', 2),
(3, 1, 114, '2018-03-01 09:45:53', 2),
(4, 2, 80, '2018-03-01 09:46:21', 2),
(5, 2, 37, '2018-03-01 09:46:21', 2),
(6, 2, 110, '2018-03-01 09:46:21', 2),
(7, 2, 115, '2018-03-01 09:46:21', 2),
(8, 3, 110, '2018-03-01 09:46:39', 2),
(9, 3, 111, '2018-03-01 09:46:39', 2),
(10, 3, 114, '2018-03-01 09:46:39', 2),
(11, 4, 80, '2018-03-01 09:47:00', 2),
(12, 4, 37, '2018-03-01 09:47:00', 2),
(13, 4, 110, '2018-03-01 09:47:00', 2),
(14, 4, 115, '2018-03-01 09:47:00', 2),
(15, 5, 80, '2018-03-01 09:47:25', 2),
(16, 5, 37, '2018-03-01 09:47:25', 2),
(17, 5, 115, '2018-03-01 09:47:25', 2),
(18, 6, 110, '2018-03-01 09:47:42', 2),
(19, 6, 115, '2018-03-01 09:47:42', 2),
(20, 7, 110, '2018-03-01 09:48:29', 2),
(21, 7, 111, '2018-03-01 09:48:29', 2),
(22, 7, 114, '2018-03-01 09:48:29', 2),
(23, 8, 80, '2018-03-01 09:48:47', 2),
(24, 8, 37, '2018-03-01 09:48:47', 2),
(25, 8, 115, '2018-03-01 09:48:47', 2),
(26, 9, 80, '2018-03-01 09:49:14', 2),
(27, 9, 37, '2018-03-01 09:49:14', 2),
(28, 9, 110, '2018-03-01 09:49:14', 2),
(29, 9, 115, '2018-03-01 09:49:14', 2),
(30, 10, 110, '2018-03-01 09:49:26', 2),
(31, 10, 115, '2018-03-01 09:49:26', 2),
(32, 11, 80, '2018-03-01 09:50:42', 2),
(33, 11, 37, '2018-03-01 09:50:42', 2),
(34, 11, 110, '2018-03-01 09:50:42', 2),
(35, 11, 115, '2018-03-01 09:50:42', 2),
(36, 12, 80, '2018-03-01 09:58:16', 3),
(37, 12, 153, '2018-03-01 09:58:16', 3),
(38, 12, 37, '2018-03-01 09:58:16', 3),
(39, 12, 110, '2018-03-01 09:58:16', 3),
(40, 12, 201, '2018-03-01 09:58:16', 3),
(41, 12, 115, '2018-03-01 09:58:16', 3),
(42, 13, 80, '2018-03-01 09:58:51', 3),
(43, 13, 153, '2018-03-01 09:58:51', 3),
(44, 13, 37, '2018-03-01 09:58:51', 3),
(45, 13, 110, '2018-03-01 09:58:51', 3),
(46, 13, 201, '2018-03-01 09:58:51', 3),
(47, 13, 115, '2018-03-01 09:58:51', 3),
(48, 14, 80, '2018-03-01 09:59:08', 3),
(49, 14, 37, '2018-03-01 09:59:08', 3),
(50, 14, 110, '2018-03-01 09:59:08', 3),
(51, 15, 201, '2018-03-01 09:59:25', 3),
(52, 15, 115, '2018-03-01 09:59:25', 3),
(53, 16, 80, '2018-03-01 09:59:38', 3),
(54, 16, 153, '2018-03-01 09:59:38', 3),
(55, 16, 37, '2018-03-01 09:59:38', 3),
(56, 16, 110, '2018-03-01 09:59:38', 3),
(57, 16, 201, '2018-03-01 09:59:38', 3),
(58, 16, 115, '2018-03-01 09:59:38', 3),
(59, 17, 37, '2018-03-01 10:00:21', 3),
(60, 17, 110, '2018-03-01 10:00:21', 3),
(61, 17, 114, '2018-03-01 10:00:21', 3),
(62, 17, 201, '2018-03-01 10:00:21', 3),
(63, 17, 115, '2018-03-01 10:00:21', 3),
(64, 18, 37, '2018-03-01 10:00:30', 3),
(65, 18, 110, '2018-03-01 10:00:30', 3),
(66, 18, 114, '2018-03-01 10:00:30', 3),
(67, 18, 201, '2018-03-01 10:00:30', 3),
(68, 18, 115, '2018-03-01 10:00:30', 3),
(69, 19, 37, '2018-03-01 10:01:15', 3),
(70, 19, 110, '2018-03-01 10:01:15', 3),
(71, 19, 114, '2018-03-01 10:01:15', 3),
(72, 19, 201, '2018-03-01 10:01:15', 3),
(73, 19, 115, '2018-03-01 10:01:15', 3),
(74, 20, 37, '2018-03-01 10:01:21', 3),
(75, 20, 110, '2018-03-01 10:01:21', 3),
(76, 20, 114, '2018-03-01 10:01:21', 3),
(77, 20, 201, '2018-03-01 10:01:21', 3),
(78, 20, 115, '2018-03-01 10:01:21', 3),
(79, 21, 37, '2018-03-01 10:01:26', 3),
(80, 21, 110, '2018-03-01 10:01:26', 3),
(81, 21, 114, '2018-03-01 10:01:26', 3),
(82, 21, 201, '2018-03-01 10:01:26', 3),
(83, 21, 115, '2018-03-01 10:01:26', 3),
(84, 1, 89, '2018-03-27 06:21:12', 2);

-- --------------------------------------------------------

--
-- Table structure for table `interviews`
--

CREATE TABLE `interviews` (
  `id` int(11) NOT NULL,
  `job_application_id` int(11) NOT NULL,
  `interviewer_id` int(11) DEFAULT NULL,
  `round_no` tinyint(4) NOT NULL,
  `round_name` varchar(255) DEFAULT NULL,
  `interview_datetime` datetime DEFAULT NULL,
  `interview_end_datetime` datetime DEFAULT NULL,
  `type_of_interview` varchar(255) DEFAULT NULL,
  `location` varchar(500) DEFAULT NULL,
  `comments` varchar(255) DEFAULT NULL,
  `status` enum('scheduled','cancelled','completed','skip') NOT NULL DEFAULT 'scheduled',
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `interviews`
--

INSERT INTO `interviews` (`id`, `job_application_id`, `interviewer_id`, `round_no`, `round_name`, `interview_datetime`, `interview_end_datetime`, `type_of_interview`, `location`, `comments`, `status`, `created`, `created_by`) VALUES
(1, 12, 17, 1, 'Face to face', '2018-03-29 08:40:00', '2018-03-30 09:00:00', 'face_to_face', '', '', 'scheduled', '2018-03-27 08:44:10', 20),
(5, 36, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 07:01:19', 20),
(6, 36, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 07:41:57', 20),
(7, 36, 18, 3, 'sdf', '2018-03-31 10:25:00', '2018-03-31 14:25:00', 'face_to_face', '', NULL, 'completed', '2018-03-30 07:43:53', 20),
(8, 36, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 07:45:05', 20),
(9, 37, 17, 1, 'GEnreal', '2018-03-31 10:25:00', '2018-04-07 10:25:00', 'face_to_face', '', NULL, 'completed', '2018-03-30 09:03:45', 20),
(10, 37, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:04:36', 20),
(11, 37, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:04:39', 20),
(12, 37, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:04:41', 20),
(13, 37, NULL, 5, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:04:42', 20),
(14, 37, NULL, 6, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:04:44', 20),
(15, 37, 17, 7, 'dfg', '2018-03-31 14:05:00', '2018-04-05 09:05:00', 'face_to_face', '', NULL, 'skip', '2018-03-30 09:07:56', 20),
(16, 38, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:15:15', 20),
(17, 38, 17, 2, 'Face to face', '2018-03-31 09:20:00', '2018-04-07 09:25:00', 'face_to_face', '', NULL, 'skip', '2018-03-30 09:15:49', 20),
(18, 38, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:15:58', 20),
(19, 38, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:16:01', 20),
(20, 39, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:16:59', 20),
(21, 39, 16, 2, 'HR', '2018-03-31 06:25:00', '2018-03-31 10:25:00', 'face_to_face', '', NULL, 'skip', '2018-03-30 09:17:15', 20),
(22, 39, NULL, 3, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:19:50', 20),
(23, 39, NULL, 4, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-03-30 09:19:53', 20),
(24, 1, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-04-02 06:58:05', 20),
(25, 1, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-04-02 06:58:08', 20),
(26, 1, 25, 3, 'Hr Senior', '2018-04-20 10:05:00', '2018-04-21 10:05:00', 'face_to_face', '', NULL, 'skip', '2018-04-02 07:10:12', 20),
(27, 2, 17, 1, 'dsad', '2018-04-19 05:00:00', '2018-04-26 09:20:00', 'telephonic', '', NULL, 'completed', '2018-04-02 07:14:15', 20),
(28, 2, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-04-02 07:14:20', 20),
(29, 2, 23, 3, 'dsfds', '2018-04-19 09:20:00', '2018-04-20 07:25:00', 'telephonic', '', NULL, 'completed', '2018-04-02 07:18:00', 20),
(30, 3, 17, 1, 'dsfds', '2018-04-10 03:55:00', '2018-04-20 06:05:00', 'face_to_face', '', NULL, 'skip', '2018-04-02 11:42:35', 20),
(31, 3, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'skip', '2018-04-02 11:43:32', 20);

-- --------------------------------------------------------

--
-- Table structure for table `interviews_feedback`
--

CREATE TABLE `interviews_feedback` (
  `id` int(11) NOT NULL,
  `interview_id` int(11) NOT NULL,
  `mode_of_interview` varchar(255) DEFAULT NULL,
  `discipline` varchar(255) DEFAULT NULL,
  `overall_comments` varchar(255) DEFAULT NULL,
  `feedback` varchar(25) NOT NULL,
  `attachment` varchar(100) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `interviews_feedback_core_skills`
--

CREATE TABLE `interviews_feedback_core_skills` (
  `id` int(11) NOT NULL,
  `interview_feedback_id` int(11) NOT NULL,
  `skill_name` varchar(50) DEFAULT NULL,
  `skill_level` varchar(50) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` int(11) NOT NULL,
  `client_id` int(11) NOT NULL,
  `owner_id` int(11) NOT NULL,
  `title` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(20000) COLLATE utf8_unicode_ci NOT NULL,
  `description_visibility` enum('show','hide') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'show',
  `keywords` mediumtext COLLATE utf8_unicode_ci NOT NULL,
  `work_exp_min` tinyint(4) NOT NULL DEFAULT '0',
  `work_exp_max` tinyint(4) NOT NULL DEFAULT '0',
  `annual_ctc_curr` char(3) COLLATE utf8_unicode_ci NOT NULL,
  `annual_ctc_min` tinyint(4) NOT NULL DEFAULT '0',
  `annual_ctc_max` tinyint(4) NOT NULL DEFAULT '0',
  `annual_ctc_visibility` enum('show','hide') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'show',
  `no_of_positions` int(11) NOT NULL,
  `industry_id` int(11) NOT NULL,
  `functional_area_id` int(11) NOT NULL,
  `job_role` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `job_type` enum('permanent','temporary') COLLATE utf8_unicode_ci NOT NULL,
  `employment_type` enum('full_time','part_time') COLLATE utf8_unicode_ci NOT NULL,
  `no_of_rounds` tinyint(4) NOT NULL,
  `prefer_female` tinyint(4) NOT NULL DEFAULT '0',
  `prefer_female_rejoin` tinyint(4) NOT NULL DEFAULT '0',
  `view_count` int(11) NOT NULL DEFAULT '0',
  `publish_date` date NOT NULL,
  `valid_till` date NOT NULL,
  `status` enum('active','inactive','expired','closed') COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `client_id`, `owner_id`, `title`, `description`, `description_visibility`, `keywords`, `work_exp_min`, `work_exp_max`, `annual_ctc_curr`, `annual_ctc_min`, `annual_ctc_max`, `annual_ctc_visibility`, `no_of_positions`, `industry_id`, `functional_area_id`, `job_role`, `job_type`, `employment_type`, `no_of_rounds`, `prefer_female`, `prefer_female_rejoin`, `view_count`, `publish_date`, `valid_till`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 5, 3, 'First Job', '<p>First Job</p>', 'show', 'First job', 1, 3, 'INR', 1, 9, 'show', 3, 3, 398, 'First job', 'permanent', 'full_time', 3, 0, 0, 13, '2018-03-26', '2018-04-07', 'active', '2018-03-26 06:10:07', 20, '2018-03-30 09:18:02', 20),
(2, 5, 21, 'Second Job', '<p>Second Job</p>', 'show', 'First job', 3, 5, 'INR', 2, 4, 'show', 3, 3, 399, 'second Job', 'permanent', 'full_time', 4, 0, 0, 0, '2018-03-26', '2018-04-28', 'active', '2018-03-26 06:47:55', 24, NULL, NULL),
(3, 4, 3, 'Test Job', '<p>Tes tJob</p>', 'show', 'First job', 2, 4, 'INR', 1, 4, 'show', 2, 3, 398, 'Tes tJob', 'permanent', 'part_time', 2, 0, 0, 6, '2018-03-26', '2018-04-07', 'active', '2018-03-26 11:49:59', 20, '2018-04-02 06:57:37', 20),
(4, 5, 20, 'Third Job', '<p>Test&nbsp;</p>', 'show', 'First job', 2, 4, 'INR', 1, 4, 'show', 3, 5, 399, 'BA', 'permanent', 'full_time', 3, 0, 0, 2, '2018-03-27', '2018-04-07', 'active', '2018-03-27 08:05:42', 20, '2018-03-30 10:55:42', 20);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_applications`
--

CREATE TABLE `jobs_applications` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `referral` varchar(255) DEFAULT NULL COMMENT 'referral candidate email address',
  `comments` varchar(255) DEFAULT NULL,
  `rating` tinyint(4) DEFAULT '0',
  `status` enum('applied','shortlisted','saved','rejected','cancelled','accepted','not_interested') DEFAULT 'applied',
  `internal_hr_id` int(11) DEFAULT NULL,
  `external_hr_id` int(11) DEFAULT NULL,
  `interviewer_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_applications`
--

INSERT INTO `jobs_applications` (`id`, `job_id`, `user_id`, `referral`, `comments`, `rating`, `status`, `internal_hr_id`, `external_hr_id`, `interviewer_id`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(4, 3, 35, NULL, NULL, 0, 'shortlisted', 20, 25, NULL, '2018-04-03 06:02:06', 20, '2018-04-03 08:02:08', NULL),
(5, 3, 36, NULL, NULL, 0, 'shortlisted', 20, 25, NULL, '2018-04-03 07:55:07', 20, '2018-04-03 08:14:25', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_applications_comments`
--

CREATE TABLE `jobs_applications_comments` (
  `id` int(11) NOT NULL,
  `job_application_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` varchar(250) NOT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `jobs_desired_degrees`
--

CREATE TABLE `jobs_desired_degrees` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `degree_id` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_desired_degrees`
--

INSERT INTO `jobs_desired_degrees` (`id`, `job_id`, `degree_id`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(13, 2, 4, '2018-03-26 06:47:55', 24, NULL, NULL),
(14, 2, 26, '2018-03-26 06:47:55', 24, NULL, NULL),
(17, 1, 4, '2018-03-27 08:03:05', 20, NULL, NULL),
(18, 1, 22, '2018-03-27 08:03:05', 20, NULL, NULL),
(21, 4, 5, '2018-03-27 09:54:26', 20, NULL, NULL),
(22, 4, 26, '2018-03-27 09:54:26', 20, NULL, NULL),
(23, 3, 4, '2018-04-02 06:57:37', 20, NULL, NULL),
(24, 3, 26, '2018-04-02 06:57:37', 20, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_hr`
--

CREATE TABLE `jobs_hr` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `hr_id` int(11) NOT NULL,
  `type` varchar(255) NOT NULL,
  `created` datetime NOT NULL,
  `created_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_hr`
--

INSERT INTO `jobs_hr` (`id`, `job_id`, `hr_id`, `type`, `created`, `created_by`) VALUES
(13, 2, 24, 'internal', '2018-03-26 06:47:55', 24),
(14, 2, 25, 'external', '2018-03-26 06:47:55', 24),
(17, 1, 24, 'internal', '2018-03-27 08:03:05', 20),
(18, 1, 25, 'external', '2018-03-27 08:03:05', 20),
(21, 4, 24, 'internal', '2018-03-27 09:54:26', 20),
(22, 4, 23, 'external', '2018-03-27 09:54:26', 20),
(23, 4, 25, 'external', '2018-03-27 09:54:26', 20),
(24, 3, 22, 'internal', '2018-04-02 06:57:37', 20),
(25, 3, 25, 'external', '2018-04-02 06:57:37', 20);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_interviewers`
--

CREATE TABLE `jobs_interviewers` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `interviewer_id` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_interviewers`
--

INSERT INTO `jobs_interviewers` (`id`, `job_id`, `interviewer_id`, `created`, `created_by`) VALUES
(41, 10, 4, '2018-03-07 07:25:57', 3),
(42, 10, 16, '2018-03-07 07:25:57', 3),
(51, 16, 4, '2018-03-07 09:04:17', 3),
(52, 16, 16, '2018-03-07 09:04:17', 3),
(53, 17, 35, '2018-03-07 09:06:07', 3),
(56, 7, 35, '2018-03-07 09:11:02', 3),
(57, 7, 37, '2018-03-07 09:11:02', 3),
(80, 15, 35, '2018-03-07 09:39:31', 3),
(81, 15, 37, '2018-03-07 09:39:31', 3),
(83, 18, 4, '2018-03-07 09:42:11', 3),
(84, 19, 35, '2018-03-07 09:43:32', 3),
(85, 19, 37, '2018-03-07 09:43:32', 3),
(86, 19, 15, '2018-03-07 09:43:32', 3),
(87, 12, 4, '2018-03-07 09:46:34', 3),
(88, 12, 16, '2018-03-07 09:46:34', 3),
(98, 9, 14, '2018-03-15 07:13:45', 3),
(99, 9, 34, '2018-03-15 07:13:45', 3),
(112, 34, 14, '2018-03-15 11:58:51', 3),
(113, 34, 33, '2018-03-15 11:58:51', 3),
(114, 35, 14, '2018-03-15 11:59:40', 3),
(115, 35, 33, '2018-03-15 11:59:40', 3),
(116, 36, 33, '2018-03-15 12:01:01', 3),
(117, 27, 14, '2018-03-15 12:01:17', 3),
(118, 27, 33, '2018-03-15 12:01:17', 3),
(120, 37, 33, '2018-03-15 12:12:21', 3),
(121, 38, 14, '2018-03-15 12:31:42', 3),
(122, 38, 33, '2018-03-15 12:31:42', 3),
(134, 2, 16, '2018-03-16 07:19:28', 20),
(135, 2, 17, '2018-03-16 07:19:28', 20),
(145, 2, 18, '2018-03-26 06:47:55', 24),
(147, 1, 18, '2018-03-27 08:03:05', 20),
(149, 4, 17, '2018-03-27 09:54:26', 20),
(150, 4, 19, '2018-03-27 09:54:26', 20),
(151, 3, 16, '2018-04-02 06:57:37', 20);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_locations`
--

CREATE TABLE `jobs_locations` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `location_id` int(11) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_locations`
--

INSERT INTO `jobs_locations` (`id`, `job_id`, `location_id`, `created`, `created_by`) VALUES
(7, 2, 61, '2018-03-26 06:47:55', 24),
(9, 1, 63, '2018-03-27 08:03:05', 20),
(11, 4, 60, '2018-03-27 09:54:26', 20),
(12, 3, 39, '2018-04-02 06:57:37', 20);

-- --------------------------------------------------------

--
-- Table structure for table `jobs_users`
--

CREATE TABLE `jobs_users` (
  `id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_job_sent` tinyint(4) DEFAULT '0',
  `job_sent_datetime` datetime DEFAULT NULL,
  `job_sent_by` int(11) DEFAULT NULL,
  `status` varchar(255) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `job_approved_datetime` datetime DEFAULT NULL,
  `job_approved_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `jobs_users`
--

INSERT INTO `jobs_users` (`id`, `job_id`, `user_id`, `is_job_sent`, `job_sent_datetime`, `job_sent_by`, `status`, `created`, `created_by`, `job_approved_datetime`, `job_approved_by`) VALUES
(20, 4, 4, 1, '2018-03-28 08:04:35', 20, 'approved', '2018-03-28 07:04:27', 20, '2018-03-28 08:01:44', 20),
(21, 4, 5, 1, '2018-03-28 08:04:35', 20, 'approved', '2018-03-28 07:04:27', 20, '2018-03-28 08:01:50', 20),
(22, 4, 6, 1, '2018-03-28 08:04:35', 20, 'approved', '2018-03-28 07:04:34', 20, '2018-03-28 08:01:50', 20),
(23, 4, 8, 1, '2018-03-28 08:04:35', 20, 'approved', '2018-03-28 07:04:34', 20, '2018-03-28 08:01:44', 20),
(24, 3, 8, 1, '2018-03-29 13:09:31', 20, 'approved', '2018-03-29 13:09:07', 20, '2018-03-29 13:09:16', 20),
(25, 3, 4, 1, '2018-03-30 10:53:13', 20, 'approved', '2018-03-29 13:15:00', 20, '2018-03-29 13:15:12', 20),
(26, 1, 4, 1, '2018-03-30 08:42:52', 20, 'approved', '2018-03-30 08:42:09', 20, '2018-03-30 08:42:19', 20),
(27, 1, 5, 1, '2018-03-30 08:42:52', 20, 'approved', '2018-03-30 08:42:09', 20, '2018-03-30 08:42:19', 20),
(28, 3, 5, 1, '2018-03-30 10:53:53', 20, 'approved', '2018-03-30 10:53:29', 20, '2018-03-30 10:53:39', 20),
(29, 3, 6, 1, '2018-03-30 10:53:53', 20, 'approved', '2018-03-30 10:53:29', 20, '2018-03-30 10:53:39', 20),
(30, 3, 7, 1, '2018-03-30 11:21:34', 20, 'approved', '2018-03-30 10:57:56', 20, '2018-03-30 10:58:04', 20),
(31, 1, 6, 1, '2018-03-30 12:02:56', 20, 'approved', '2018-03-30 11:57:15', 20, '2018-03-30 11:57:24', 20),
(32, 3, 39, 1, '2018-04-02 06:57:00', 20, 'approved', '2018-04-02 06:38:42', 20, '2018-04-02 06:38:50', 20),
(33, 3, 38, 1, '2018-04-02 06:57:00', 20, 'approved', '2018-04-02 06:38:42', 20, '2018-04-02 06:38:50', 20),
(34, 1, 34, 0, NULL, NULL, 'approved', '2018-04-02 06:40:43', 20, '2018-04-02 06:40:51', 20),
(35, 4, 46, 0, NULL, NULL, 'approved', '2018-04-02 09:56:58', 23, '2018-04-02 11:41:38', 20),
(36, 3, 34, 1, '2018-04-02 11:41:49', 20, 'approved', '2018-04-02 11:41:27', 20, '2018-04-02 11:41:38', 20),
(37, 3, 35, 1, '2018-04-03 06:02:06', 20, 'approved', '2018-04-03 06:01:34', 20, '2018-04-03 06:01:42', 20),
(38, 3, 36, 1, '2018-04-03 07:55:07', 20, 'approved', '2018-04-03 07:54:47', 20, '2018-04-03 07:54:56', 20);

-- --------------------------------------------------------

--
-- Table structure for table `logs`
--

CREATE TABLE `logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `last_login` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `logs`
--

INSERT INTO `logs` (`id`, `user_id`, `last_login`) VALUES
(1, 1, '2018-03-26 06:00:20'),
(2, 20, '2018-03-26 06:08:50'),
(3, 1, '2018-03-26 06:14:48'),
(4, 23, '2018-03-26 06:15:08'),
(5, 1, '2018-03-26 06:15:48'),
(6, 22, '2018-03-26 06:16:08'),
(7, 1, '2018-03-26 06:35:38'),
(8, 24, '2018-03-26 06:37:24'),
(9, 25, '2018-03-26 06:51:51'),
(10, 1, '2018-03-26 06:58:21'),
(11, 2, '2018-03-26 07:16:24'),
(12, 26, '2018-03-26 07:17:08'),
(13, 1, '2018-03-26 07:17:19'),
(14, 20, '2018-03-26 07:22:53'),
(15, 20, '2018-03-26 08:42:40'),
(16, 20, '2018-03-26 09:32:25'),
(17, 16, '2018-03-26 10:21:12'),
(18, 20, '2018-03-26 10:23:36'),
(19, 1, '2018-03-26 10:33:50'),
(20, 3, '2018-03-26 10:34:11'),
(21, 20, '2018-03-26 10:35:55'),
(22, 3, '2018-03-26 10:40:13'),
(23, 20, '2018-03-26 10:45:38'),
(24, 1, '2018-03-26 11:35:11'),
(25, 20, '2018-03-26 11:35:36'),
(26, 20, '2018-03-26 11:41:48'),
(27, 3, '2018-03-26 11:43:09'),
(28, 1, '2018-03-26 11:43:41'),
(29, 2, '2018-03-26 11:45:29'),
(30, 3, '2018-03-26 11:47:06'),
(31, 20, '2018-03-26 11:47:52'),
(32, 21, '2018-03-26 11:52:38'),
(33, 20, '2018-03-26 11:53:07'),
(34, 5, '2018-03-26 12:07:38'),
(35, 20, '2018-03-26 12:51:42'),
(36, 20, '2018-03-26 12:52:50'),
(37, 2, '2018-03-27 06:20:52'),
(38, 1, '2018-03-27 06:24:05'),
(39, 21, '2018-03-27 07:22:18'),
(40, 1, '2018-03-27 07:26:17'),
(41, 20, '2018-03-27 07:26:47'),
(42, 1, '2018-03-27 07:31:05'),
(43, 20, '2018-03-27 07:36:16'),
(44, 3, '2018-03-27 07:36:34'),
(45, 20, '2018-03-27 08:01:49'),
(46, 3, '2018-03-27 08:03:17'),
(47, 20, '2018-03-27 08:04:41'),
(48, 3, '2018-03-27 08:05:54'),
(49, 20, '2018-03-27 08:07:38'),
(50, 3, '2018-03-27 08:21:03'),
(51, 25, '2018-03-27 08:21:21'),
(52, 20, '2018-03-27 08:34:49'),
(53, 25, '2018-03-27 08:35:28'),
(54, 20, '2018-03-27 08:40:03'),
(55, 5, '2018-03-27 08:41:33'),
(56, 20, '2018-03-27 08:41:50'),
(57, 20, '2018-03-27 08:58:06'),
(58, 20, '2018-03-27 09:53:47'),
(59, 1, '2018-03-27 10:20:41'),
(60, 20, '2018-03-27 10:26:01'),
(61, 1, '2018-03-27 11:04:28'),
(62, 20, '2018-03-27 11:06:38'),
(63, 25, '2018-03-27 11:45:47'),
(64, 25, '2018-03-27 12:42:52'),
(65, 20, '2018-03-27 12:57:32'),
(66, 4, '2018-03-28 06:34:30'),
(67, 20, '2018-03-28 06:35:05'),
(68, 20, '2018-03-28 08:00:18'),
(69, 1, '2018-03-28 08:08:46'),
(70, 1, '2018-03-28 08:32:31'),
(71, 4, '2018-03-28 08:32:53'),
(72, 4, '2018-03-28 09:39:33'),
(73, 2, '2018-03-28 10:28:42'),
(74, 4, '2018-03-28 10:30:09'),
(75, 1, '2018-03-28 11:38:40'),
(76, 4, '2018-03-28 11:55:33'),
(77, 26, '2018-03-28 11:59:10'),
(78, 32, '2018-03-28 12:12:00'),
(79, 4, '2018-03-28 12:18:32'),
(80, 4, '2018-03-29 07:11:52'),
(81, 1, '2018-03-29 07:12:09'),
(82, 3, '2018-03-29 07:12:51'),
(83, 4, '2018-03-29 08:25:38'),
(84, 4, '2018-03-29 08:40:39'),
(85, 2, '2018-03-29 08:45:19'),
(86, 2, '2018-03-29 08:50:11'),
(87, 4, '2018-03-29 08:50:37'),
(88, 4, '2018-03-29 10:01:19'),
(89, 4, '2018-03-29 11:41:08'),
(90, 20, '2018-03-29 13:07:42'),
(91, 2, '2018-03-29 13:09:43'),
(92, 3, '2018-03-29 13:10:11'),
(93, 20, '2018-03-29 13:14:41'),
(94, 20, '2018-03-30 06:04:25'),
(95, 20, '2018-03-30 07:16:40'),
(96, 16, '2018-03-30 07:49:40'),
(97, 20, '2018-03-30 07:50:10'),
(98, 20, '2018-03-30 08:46:22'),
(99, 16, '2018-03-30 09:17:29'),
(100, 5, '2018-03-30 09:17:53'),
(101, 20, '2018-03-30 09:18:26'),
(102, 16, '2018-03-30 09:49:07'),
(103, 20, '2018-03-30 10:09:54'),
(104, 20, '2018-03-30 10:11:01'),
(105, 20, '2018-03-30 10:41:28'),
(106, 20, '2018-03-30 10:52:46'),
(107, 4, '2018-03-30 10:54:04'),
(108, 5, '2018-03-30 10:54:34'),
(109, 4, '2018-03-30 10:55:37'),
(110, 6, '2018-03-30 10:56:02'),
(111, 20, '2018-03-30 10:57:33'),
(112, 4, '2018-03-30 11:17:27'),
(113, 20, '2018-03-30 11:17:48'),
(114, 20, '2018-03-30 11:55:29'),
(115, 3, '2018-03-30 12:13:01'),
(116, 3, '2018-03-30 12:15:13'),
(117, 20, '2018-03-30 12:20:09'),
(118, 3, '2018-03-30 12:23:20'),
(119, 20, '2018-03-30 12:24:01'),
(120, 20, '2018-03-30 12:33:15'),
(121, 3, '2018-03-30 12:33:24'),
(122, 20, '2018-03-30 12:33:53'),
(123, 16, '2018-03-30 13:23:14'),
(124, 20, '2018-04-02 06:08:28'),
(125, 3, '2018-04-02 06:33:19'),
(126, 20, '2018-04-02 06:33:38'),
(127, 3, '2018-04-02 06:34:02'),
(128, 20, '2018-04-02 06:37:54'),
(129, 20, '2018-04-02 06:56:33'),
(130, 3, '2018-04-02 07:37:09'),
(131, 23, '2018-04-02 07:37:29'),
(132, 3, '2018-04-02 08:20:09'),
(133, 20, '2018-04-02 08:54:12'),
(134, 4, '2018-04-02 08:56:09'),
(135, 20, '2018-04-02 09:27:23'),
(136, 3, '2018-04-02 09:35:53'),
(137, 20, '2018-04-02 09:37:15'),
(138, 3, '2018-04-02 09:37:33'),
(139, 23, '2018-04-02 09:55:50'),
(140, 3, '2018-04-02 09:58:33'),
(141, 3, '2018-04-02 10:17:47'),
(142, 3, '2018-04-02 10:22:48'),
(143, 3, '2018-04-02 10:34:35'),
(144, 3, '2018-04-02 10:34:59'),
(145, 3, '2018-04-02 10:36:14'),
(146, 4, '2018-04-02 10:36:23'),
(147, 4, '2018-04-02 10:37:00'),
(148, 20, '2018-04-02 10:37:09'),
(149, 17, '2018-04-02 11:42:50'),
(150, 20, '2018-04-02 11:43:13'),
(151, 17, '2018-04-02 11:43:42'),
(152, 20, '2018-04-02 11:48:26'),
(153, 3, '2018-04-02 12:49:21'),
(154, 20, '2018-04-02 12:50:18'),
(155, 20, '2018-04-02 12:52:27'),
(156, 3, '2018-04-02 12:57:14'),
(157, 3, '2018-04-02 13:16:22'),
(158, 3, '2018-04-02 13:23:48'),
(159, 3, '2018-04-02 13:29:04'),
(160, 3, '2018-04-02 13:29:50'),
(161, 3, '2018-04-02 13:32:05'),
(162, 20, '2018-04-03 05:49:42'),
(163, 1, '2018-04-03 07:57:40'),
(164, 25, '2018-04-03 07:57:58'),
(165, 20, '2018-04-03 08:02:18'),
(166, 25, '2018-04-03 08:11:06'),
(167, 20, '2018-04-03 09:37:15'),
(168, 3, '2018-04-03 11:25:56'),
(169, 3, '2018-04-03 11:35:28'),
(170, 20, '2018-04-03 12:08:47'),
(171, 3, '2018-04-04 06:07:54'),
(172, 20, '2018-04-04 06:42:15'),
(173, 3, '2018-04-04 06:44:31'),
(174, 20, '2018-04-04 06:46:03');

-- --------------------------------------------------------

--
-- Table structure for table `masters_cities`
--

CREATE TABLE `masters_cities` (
  `id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  `state` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `masters_cities`
--

INSERT INTO `masters_cities` (`id`, `country_id`, `state`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 99, 'Union Territories', 'Chandi*garh', 'active', '2018-01-30 17:41:15', 1, '2018-05-29 12:03:20', NULL),
(2, 99, 'Union Territories', 'Dadra & Nagar Haveli - Silvassa', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(3, 99, 'Union Territories', 'Daman & Diu', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(4, 99, 'Union Territories', 'Pondicherry', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(5, 99, 'Andhra Pradesh', 'Anantapur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(6, 99, 'Andhra Pradesh', 'Chittoor', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(7, 99, 'Andhra Pradesh', 'Eluru', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(8, 99, 'Andhra Pradesh', 'Gannavaram', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(9, 99, 'Andhra Pradesh', 'Guntakal', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(10, 99, 'Andhra Pradesh', 'Guntur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(11, 99, 'Andhra Pradesh', 'Kadapa / Cuddapah', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(12, 99, 'Andhra Pradesh', 'Kakinada', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(13, 99, 'Andhra Pradesh', 'Kurnool', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(14, 99, 'Andhra Pradesh', 'Machilipatnam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(15, 99, 'Andhra Pradesh', 'Nandyal', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(16, 99, 'Andhra Pradesh', 'Nellore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(17, 99, 'Andhra Pradesh', 'Ongole', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(18, 99, 'Andhra Pradesh', 'Rajahmundry', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(19, 99, 'Andhra Pradesh', 'Tada', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(20, 99, 'Andhra Pradesh', 'Tirupati', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(21, 99, 'Andhra Pradesh', 'Vijayawada', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(22, 99, 'Andhra Pradesh', 'Visakhapatnam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(23, 99, 'Andhra Pradesh', 'Vizianagaram', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(24, 99, 'Andhra Pradesh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(25, 99, 'Arunachal Pradesh', 'Itanagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(26, 99, 'Arunachal Pradesh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(27, 99, 'Assam', 'Guwahati', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(28, 99, 'Assam', 'Silchar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(29, 99, 'Assam', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(30, 99, 'Bihar', 'Bhagalpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(31, 99, 'Bihar', 'Patna', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(32, 99, 'Bihar', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(33, 99, 'Chhattisgarh', 'Bhila', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(34, 99, 'Chhattisgarh', 'Bilaspur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(35, 99, 'Chhattisgarh', 'Raipur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(36, 99, 'Chhattisgarh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(37, 99, 'Delhi', 'Delhi', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(38, 99, 'Goa', 'Panjim', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(39, 99, 'Goa', 'Vasco De Gama', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(40, 99, 'Goa', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(41, 99, 'Gujarat', 'Ahmedabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(42, 99, 'Gujarat', 'Anand', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(43, 99, 'Gujarat', 'Ankleshwar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(44, 99, 'Gujarat', 'Baroda', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(45, 99, 'Gujarat', 'Bharuch', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(46, 99, 'Gujarat', 'Bhavnagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(47, 99, 'Gujarat', 'Bhuj', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(48, 99, 'Gujarat', 'Gir', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(49, 99, 'Gujarat', 'Gandhinagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(50, 99, 'Gujarat', 'Jamnagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(51, 99, 'Gujarat', 'Kandla', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(52, 99, 'Gujarat', 'Porbandar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(53, 99, 'Gujarat', 'Rajkot', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(54, 99, 'Gujarat', 'Surat ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(55, 99, 'Gujarat', 'Valsad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(56, 99, 'Gujarat', 'Vapi', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(57, 99, 'Gujarat', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(58, 99, 'Haryana', 'Ambala', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(59, 99, 'Haryana', 'Faridabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(60, 99, 'Haryana', 'Gurgaon', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(61, 99, 'Haryana', 'Hisar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(62, 99, 'Haryana', 'Karnal', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(63, 99, 'Haryana', 'Kurukshetra', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(64, 99, 'Haryana', 'Panipat', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(65, 99, 'Haryana', 'Rohtak', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(66, 99, 'Haryana', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(67, 99, 'Himachal Pradesh', 'Dalhousie', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(68, 99, 'Himachal Pradesh', 'Dharamshala', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(69, 99, 'Himachal Pradesh', 'Kulu / Manali', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(70, 99, 'Himachal Pradesh', 'Shimla', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(71, 99, 'Himachal Pradesh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(72, 99, 'Jammu & Kashmir', 'Jammu', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(73, 99, 'Jammu & Kashmir', 'Srinagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(74, 99, 'Jammu & Kashmir', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(75, 99, 'Jharkhand', 'Bokaro', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(76, 99, 'Jharkhand', 'Dhanbad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(77, 99, 'Jharkhand', 'Jamshedpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(78, 99, 'Jharkhand', 'Ranchi', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(79, 99, 'Jharkhand', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(80, 99, 'Karnataka', 'Bengaluru', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(81, 99, 'Karnataka', 'Belgaum', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(82, 99, 'Karnataka', 'Bellary', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(83, 99, 'Karnataka', 'Bidar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(84, 99, 'Karnataka', 'Dharwad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(85, 99, 'Karnataka', 'Gulbarga', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(86, 99, 'Karnataka', 'Hubli ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(87, 99, 'Karnataka', 'Kolar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(88, 99, 'Karnataka', 'Mangalore ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(89, 99, 'Karnataka', 'Mysore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(90, 99, 'Karnataka', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(91, 99, 'Kerala', 'Kozhikode / Calicut', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(92, 99, 'Kerala', 'Ernakulam / Kochi / Cochin', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(93, 99, 'Kerala', 'Kannur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(94, 99, 'Kerala', 'Kollam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(95, 99, 'Kerala', 'Kottayam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(96, 99, 'Kerala', 'Palakkad / Palghat', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(97, 99, 'Kerala', 'Thrissur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(98, 99, 'Kerala', 'Trivandrum', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(99, 99, 'Kerala', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(100, 99, 'Madhya Pradesh', 'Bhopal ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(101, 99, 'Madhya Pradesh', 'Gwalior', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(102, 99, 'Madhya Pradesh', 'Indore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(103, 99, 'Madhya Pradesh', 'Jabalpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(104, 99, 'Madhya Pradesh', 'Ujjain', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(105, 99, 'Madhya Pradesh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(106, 99, 'Maharashtra', 'Ahmednagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(107, 99, 'Maharashtra', 'Aurangabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(108, 99, 'Maharashtra', 'Jalgaon', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(109, 99, 'Maharashtra', 'Kolhapur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(110, 99, 'Maharashtra', 'Mumbai', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(111, 99, 'Maharashtra', 'Mumbai - Suburbs', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(112, 99, 'Maharashtra', 'Nagpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(113, 99, 'Maharashtra', 'Nashik', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(114, 99, 'Maharashtra', 'Navi Mumbai ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(115, 99, 'Maharashtra', 'Pune', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(116, 99, 'Maharashtra', 'Solapur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(117, 99, 'Maharashtra', 'Satara', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(118, 99, 'Maharashtra', 'Sangli ', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(119, 99, 'Maharashtra', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(120, 99, 'Manipur', 'Imphal', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(121, 99, 'Manipur', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(122, 99, 'Meghalaya', 'Shillong', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(123, 99, 'Meghalaya', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(124, 99, 'Mizoram', 'Aizawl', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(125, 99, 'Mizoram', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(126, 99, 'Nagaland', 'Dimapur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(127, 99, 'Nagaland', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(128, 99, 'Orissa', 'Bhubaneshwar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(129, 99, 'Orissa', 'Cuttack', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(130, 99, 'Orissa', 'Paradeep', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(131, 99, 'Orissa', 'Puri', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(132, 99, 'Orissa', 'Rourkela', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(133, 99, 'Orissa', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(134, 99, 'Punjab', 'Amritsar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(135, 99, 'Punjab', 'Bathinda', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(136, 99, 'Punjab', 'Jalandhar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(137, 99, 'Punjab', 'Ludhiana', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(138, 99, 'Punjab', 'Mohali', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(139, 99, 'Punjab', 'Pathankot', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(140, 99, 'Punjab', 'Patiala', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(141, 99, 'Punjab', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(142, 99, 'Rajasthan', 'Ajmer', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(143, 99, 'Rajasthan', 'Jaipur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(144, 99, 'Rajasthan', 'Jaisalmer', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(145, 99, 'Rajasthan', 'Jodhpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(146, 99, 'Rajasthan', 'Kota', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(147, 99, 'Rajasthan', 'Udaipur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(148, 99, 'Rajasthan', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(149, 99, 'Sikkim', 'Gangtok', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(150, 99, 'Sikkim', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(151, 99, 'Tamil Nadu', 'Hosur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(152, 99, 'Tamil Nadu', 'Nagercoil', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(153, 99, 'Tamil Nadu', 'Chennai', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(154, 99, 'Tamil Nadu', 'Coimbatore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(155, 99, 'Tamil Nadu', 'Cuddalore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(156, 99, 'Tamil Nadu', 'Erode', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(157, 99, 'Tamil Nadu', 'Madurai', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(158, 99, 'Tamil Nadu', 'Ooty', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(159, 99, 'Tamil Nadu', 'Salem', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(160, 99, 'Tamil Nadu', 'Thanjavur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(161, 99, 'Tamil Nadu', 'Tirunelveli', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(162, 99, 'Tamil Nadu', 'Trichy', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(163, 99, 'Tamil Nadu', 'Tuticorin', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(164, 99, 'Tamil Nadu', 'Vellore', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(165, 99, 'Tamil Nadu', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(166, 99, 'Telangana', 'Adilabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(167, 99, 'Telangana', 'Bhadrachalam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(168, 99, 'Telangana', 'Godavarikhani', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(169, 99, 'Telangana', 'Hanamkonda', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(170, 99, 'Telangana', 'Hyderabad / Secunderabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(171, 99, 'Telangana', 'Karimnagar', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(172, 99, 'Telangana', 'Khammam', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(173, 99, 'Telangana', 'Kodad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(174, 99, 'Telangana', 'Kothagudem', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(175, 99, 'Telangana', 'Mahbubnagar / Mahaboobabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(176, 99, 'Telangana', 'Mancherial', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(177, 99, 'Telangana', 'Medak', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(178, 99, 'Telangana', 'Nalgonda', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(179, 99, 'Telangana', 'Nizamabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(180, 99, 'Telangana', 'Rangareddy', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(181, 99, 'Telangana', 'Razole', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(182, 99, 'Telangana', 'Sangareddy', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(183, 99, 'Telangana', 'Siddipet', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(184, 99, 'Telangana', 'Suryapet', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(185, 99, 'Telangana', 'Tuni', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(186, 99, 'Telangana', 'Warangal', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(187, 99, 'Telangana', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(188, 99, 'Tripura', 'Agartala', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(189, 99, 'Tripura', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(190, 99, 'Uttar Pradesh', 'Agra', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(191, 99, 'Uttar Pradesh', 'Aligarh', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(192, 99, 'Uttar Pradesh', 'Allahabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(193, 99, 'Uttar Pradesh', 'Bareilly', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(194, 99, 'Uttar Pradesh', 'Faizabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(195, 99, 'Uttar Pradesh', 'Ghaziabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(196, 99, 'Uttar Pradesh', 'Gorakhpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(197, 99, 'Uttar Pradesh', 'Kanpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(198, 99, 'Uttar Pradesh', 'Lucknow', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(199, 99, 'Uttar Pradesh', 'Mathura', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(200, 99, 'Uttar Pradesh', 'Meerut', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(201, 99, 'Uttar Pradesh', 'Noida', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(202, 99, 'Uttar Pradesh', 'Varanasi', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(203, 99, 'Uttar Pradesh', 'Moradabad', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(204, 99, 'Uttar Pradesh', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(205, 99, 'Uttaranchal', 'Dehradun', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(206, 99, 'Uttaranchal', 'Roorkee', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(207, 99, 'Uttaranchal', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(208, 99, 'West Bengal', 'Asansol', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(209, 99, 'West Bengal', 'Durgapur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(210, 99, 'West Bengal', 'Haldia', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(211, 99, 'West Bengal', 'Kharagpur', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(212, 99, 'West Bengal', 'Kolkata', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(213, 99, 'West Bengal', 'Siliguri', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL),
(214, 99, 'West Bengal', 'Others', 'active', '2018-01-30 17:41:15', 1, '2018-01-30 12:11:15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_countries`
--

CREATE TABLE `masters_countries` (
  `id` int(11) NOT NULL,
  `iso` char(2) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `iso3` char(3) DEFAULT NULL,
  `numcode` smallint(6) DEFAULT NULL,
  `phonecode` int(5) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_countries`
--

INSERT INTO `masters_countries` (`id`, `iso`, `name`, `iso3`, `numcode`, `phonecode`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'AF', 'Afghanistan', 'AFG', 4, 93, 'active', NULL, NULL, NULL, NULL),
(2, 'AL', 'Albania', 'ALB', 8, 355, 'active', NULL, NULL, NULL, NULL),
(3, 'DZ', 'Algeria', 'DZA', 12, 213, 'active', NULL, NULL, NULL, NULL),
(4, 'AS', 'American Samoa', 'ASM', 16, 1684, 'active', NULL, NULL, NULL, NULL),
(5, 'AD', 'Andorra', 'AND', 20, 376, 'active', NULL, NULL, NULL, NULL),
(6, 'AO', 'Angola', 'AGO', 24, 244, 'active', NULL, NULL, NULL, NULL),
(7, 'AI', 'Anguilla', 'AIA', 660, 1264, 'active', NULL, NULL, NULL, NULL),
(8, 'AQ', 'Antarctica', NULL, NULL, 0, 'active', NULL, NULL, NULL, NULL),
(9, 'AG', 'Antigua and Barbuda', 'ATG', 28, 1268, 'active', NULL, NULL, NULL, NULL),
(10, 'AR', 'Argentina', 'ARG', 32, 54, 'active', NULL, NULL, NULL, NULL),
(11, 'AM', 'Armenia', 'ARM', 51, 374, 'active', NULL, NULL, NULL, NULL),
(12, 'AW', 'Aruba', 'ABW', 533, 297, 'active', NULL, NULL, NULL, NULL),
(13, 'AU', 'Australia', 'AUS', 36, 61, 'active', NULL, NULL, NULL, NULL),
(14, 'AT', 'Austria', 'AUT', 40, 43, 'active', NULL, NULL, NULL, NULL),
(15, 'AZ', 'Azerbaijan', 'AZE', 31, 994, 'active', NULL, NULL, NULL, NULL),
(16, 'BS', 'Bahamas', 'BHS', 44, 1242, 'active', NULL, NULL, NULL, NULL),
(17, 'BH', 'Bahrain', 'BHR', 48, 973, 'active', NULL, NULL, NULL, NULL),
(18, 'BD', 'Bangladesh', 'BGD', 50, 880, 'active', NULL, NULL, NULL, NULL),
(19, 'BB', 'Barbados', 'BRB', 52, 1246, 'active', NULL, NULL, NULL, NULL),
(20, 'BY', 'Belarus', 'BLR', 112, 375, 'active', NULL, NULL, NULL, NULL),
(21, 'BE', 'Belgium', 'BEL', 56, 32, 'active', NULL, NULL, NULL, NULL),
(22, 'BZ', 'Belize', 'BLZ', 84, 501, 'active', NULL, NULL, NULL, NULL),
(23, 'BJ', 'Benin', 'BEN', 204, 229, 'active', NULL, NULL, NULL, NULL),
(24, 'BM', 'Bermuda', 'BMU', 60, 1441, 'active', NULL, NULL, NULL, NULL),
(25, 'BT', 'Bhutan', 'BTN', 64, 975, 'active', NULL, NULL, NULL, NULL),
(26, 'BO', 'Bolivia', 'BOL', 68, 591, 'active', NULL, NULL, NULL, NULL),
(27, 'BA', 'Bosnia and Herzegovina', 'BIH', 70, 387, 'active', NULL, NULL, NULL, NULL),
(28, 'BW', 'Botswana', 'BWA', 72, 267, 'active', NULL, NULL, NULL, NULL),
(29, 'BV', 'Bouvet Island', NULL, NULL, 0, 'active', NULL, NULL, NULL, NULL),
(30, 'BR', 'Brazil', 'BRA', 76, 55, 'active', NULL, NULL, NULL, NULL),
(31, 'IO', 'British Indian Ocean Territory', NULL, NULL, 246, 'active', NULL, NULL, NULL, NULL),
(32, 'BN', 'Brunei Darussalam', 'BRN', 96, 673, 'active', NULL, NULL, NULL, NULL),
(33, 'BG', 'Bulgaria', 'BGR', 100, 359, 'active', NULL, NULL, NULL, NULL),
(34, 'BF', 'Burkina Faso', 'BFA', 854, 226, 'active', NULL, NULL, NULL, NULL),
(35, 'BI', 'Burundi', 'BDI', 108, 257, 'active', NULL, NULL, NULL, NULL),
(36, 'KH', 'Cambodia', 'KHM', 116, 855, 'active', NULL, NULL, NULL, NULL),
(37, 'CM', 'Cameroon', 'CMR', 120, 237, 'active', NULL, NULL, NULL, NULL),
(38, 'CA', 'Canada', 'CAN', 124, 1, 'active', NULL, NULL, NULL, NULL),
(39, 'CV', 'Cape Verde', 'CPV', 132, 238, 'active', NULL, NULL, NULL, NULL),
(40, 'KY', 'Cayman Islands', 'CYM', 136, 1345, 'active', NULL, NULL, NULL, NULL),
(41, 'CF', 'Central African Republic', 'CAF', 140, 236, 'active', NULL, NULL, NULL, NULL),
(42, 'TD', 'Chad', 'TCD', 148, 235, 'active', NULL, NULL, NULL, NULL),
(43, 'CL', 'Chile', 'CHL', 152, 56, 'active', NULL, NULL, NULL, NULL),
(44, 'CN', 'China', 'CHN', 156, 86, 'active', NULL, NULL, NULL, NULL),
(45, 'CX', 'Christmas Island', NULL, NULL, 61, 'active', NULL, NULL, NULL, NULL),
(46, 'CC', 'Cocos (Keeling) Islands', NULL, NULL, 672, 'active', NULL, NULL, NULL, NULL),
(47, 'CO', 'Colombia', 'COL', 170, 57, 'active', NULL, NULL, NULL, NULL),
(48, 'KM', 'Comoros', 'COM', 174, 269, 'active', NULL, NULL, NULL, NULL),
(49, 'CG', 'Congo', 'COG', 178, 242, 'active', NULL, NULL, NULL, NULL),
(50, 'CD', 'Congo, the Democratic Republic of the', 'COD', 180, 242, 'active', NULL, NULL, NULL, NULL),
(51, 'CK', 'Cook Islands', 'COK', 184, 682, 'active', NULL, NULL, NULL, NULL),
(52, 'CR', 'Costa Rica', 'CRI', 188, 506, 'active', NULL, NULL, NULL, NULL),
(53, 'CI', 'Cote D\'Ivoire', 'CIV', 384, 225, 'active', NULL, NULL, NULL, NULL),
(54, 'HR', 'Croatia', 'HRV', 191, 385, 'active', NULL, NULL, NULL, NULL),
(55, 'CU', 'Cuba', 'CUB', 192, 53, 'active', NULL, NULL, NULL, NULL),
(56, 'CY', 'Cyprus', 'CYP', 196, 357, 'active', NULL, NULL, NULL, NULL),
(57, 'CZ', 'Czech Republic', 'CZE', 203, 420, 'active', NULL, NULL, NULL, NULL),
(58, 'DK', 'Denmark', 'DNK', 208, 45, 'active', NULL, NULL, NULL, NULL),
(59, 'DJ', 'Djibouti', 'DJI', 262, 253, 'active', NULL, NULL, NULL, NULL),
(60, 'DM', 'Dominica', 'DMA', 212, 1767, 'active', NULL, NULL, NULL, NULL),
(61, 'DO', 'Dominican Republic', 'DOM', 214, 1809, 'active', NULL, NULL, NULL, NULL),
(62, 'EC', 'Ecuador', 'ECU', 218, 593, 'active', NULL, NULL, NULL, NULL),
(63, 'EG', 'Egypt', 'EGY', 818, 20, 'active', NULL, NULL, NULL, NULL),
(64, 'SV', 'El Salvador', 'SLV', 222, 503, 'active', NULL, NULL, NULL, NULL),
(65, 'GQ', 'Equatorial Guinea', 'GNQ', 226, 240, 'active', NULL, NULL, NULL, NULL),
(66, 'ER', 'Eritrea', 'ERI', 232, 291, 'active', NULL, NULL, NULL, NULL),
(67, 'EE', 'Estonia', 'EST', 233, 372, 'active', NULL, NULL, NULL, NULL),
(68, 'ET', 'Ethiopia', 'ETH', 231, 251, 'active', NULL, NULL, NULL, NULL),
(69, 'FK', 'Falkland Islands (Malvinas)', 'FLK', 238, 500, 'active', NULL, NULL, NULL, NULL),
(70, 'FO', 'Faroe Islands', 'FRO', 234, 298, 'active', NULL, NULL, NULL, NULL),
(71, 'FJ', 'Fiji', 'FJI', 242, 679, 'active', NULL, NULL, NULL, NULL),
(72, 'FI', 'Finland', 'FIN', 246, 358, 'active', NULL, NULL, NULL, NULL),
(73, 'FR', 'France', 'FRA', 250, 33, 'active', NULL, NULL, NULL, NULL),
(74, 'GF', 'French Guiana', 'GUF', 254, 594, 'active', NULL, NULL, NULL, NULL),
(75, 'PF', 'French Polynesia', 'PYF', 258, 689, 'active', NULL, NULL, NULL, NULL),
(76, 'TF', 'French Southern Territories', NULL, NULL, 0, 'active', NULL, NULL, NULL, NULL),
(77, 'GA', 'Gabon', 'GAB', 266, 241, 'active', NULL, NULL, NULL, NULL),
(78, 'GM', 'Gambia', 'GMB', 270, 220, 'active', NULL, NULL, NULL, NULL),
(79, 'GE', 'Georgia', 'GEO', 268, 995, 'active', NULL, NULL, NULL, NULL),
(80, 'DE', 'Germany', 'DEU', 276, 49, 'active', NULL, NULL, NULL, NULL),
(81, 'GH', 'Ghana', 'GHA', 288, 233, 'active', NULL, NULL, NULL, NULL),
(82, 'GI', 'Gibraltar', 'GIB', 292, 350, 'active', NULL, NULL, NULL, NULL),
(83, 'GR', 'Greece', 'GRC', 300, 30, 'active', NULL, NULL, NULL, NULL),
(84, 'GL', 'Greenland', 'GRL', 304, 299, 'active', NULL, NULL, NULL, NULL),
(85, 'GD', 'Grenada', 'GRD', 308, 1473, 'active', NULL, NULL, NULL, NULL),
(86, 'GP', 'Guadeloupe', 'GLP', 312, 590, 'active', NULL, NULL, NULL, NULL),
(87, 'GU', 'Guam', 'GUM', 316, 1671, 'active', NULL, NULL, NULL, NULL),
(88, 'GT', 'Guatemala', 'GTM', 320, 502, 'active', NULL, NULL, NULL, NULL),
(89, 'GN', 'Guinea', 'GIN', 324, 224, 'active', NULL, NULL, NULL, NULL),
(90, 'GW', 'Guinea-Bissau', 'GNB', 624, 245, 'active', NULL, NULL, NULL, NULL),
(91, 'GY', 'Guyana', 'GUY', 328, 592, 'active', NULL, NULL, NULL, NULL),
(92, 'HT', 'Haiti', 'HTI', 332, 509, 'active', NULL, NULL, NULL, NULL),
(93, 'HM', 'Heard Island and Mcdonald Islands', NULL, NULL, 0, 'active', NULL, NULL, NULL, NULL),
(94, 'VA', 'Holy See (Vatican City State)', 'VAT', 336, 39, 'active', NULL, NULL, NULL, NULL),
(95, 'HN', 'Honduras', 'HND', 340, 504, 'active', NULL, NULL, NULL, NULL),
(96, 'HK', 'Hong Kong', 'HKG', 344, 852, 'active', NULL, NULL, NULL, NULL),
(97, 'HU', 'Hungary', 'HUN', 348, 36, 'active', NULL, NULL, NULL, NULL),
(98, 'IS', 'Iceland', 'ISL', 352, 354, 'active', NULL, NULL, NULL, NULL),
(99, 'IN', 'India12', 'IND', 356, 91, 'active', NULL, NULL, '2018-02-20 11:21:55', 1),
(100, 'ID', 'Indonesia', 'IDN', 360, 62, 'active', NULL, NULL, NULL, NULL),
(101, 'IR', 'Iran, Islamic Republic of', 'IRN', 364, 98, 'active', NULL, NULL, NULL, NULL),
(102, 'IQ', 'Iraq', 'IRQ', 368, 964, 'active', NULL, NULL, NULL, NULL),
(103, 'IE', 'Ireland', 'IRL', 372, 353, 'active', NULL, NULL, NULL, NULL),
(104, 'IL', 'Israel', 'ISR', 376, 972, 'active', NULL, NULL, NULL, NULL),
(105, 'IT', 'Italy', 'ITA', 380, 39, 'active', NULL, NULL, NULL, NULL),
(106, 'JM', 'Jamaica', 'JAM', 388, 1876, 'active', NULL, NULL, NULL, NULL),
(107, 'JP', 'Japan', 'JPN', 392, 81, 'active', NULL, NULL, NULL, NULL),
(108, 'JO', 'Jordan', 'JOR', 400, 962, 'active', NULL, NULL, NULL, NULL),
(109, 'KZ', 'Kazakhstan', 'KAZ', 398, 7, 'active', NULL, NULL, NULL, NULL),
(110, 'KE', 'Kenya', 'KEN', 404, 254, 'active', NULL, NULL, NULL, NULL),
(111, 'KI', 'Kiribati', 'KIR', 296, 686, 'active', NULL, NULL, NULL, NULL),
(112, 'KP', 'Korea, Democratic People\'s Republic of', 'PRK', 408, 850, 'active', NULL, NULL, NULL, NULL),
(113, 'KR', 'Korea, Republic of', 'KOR', 410, 82, 'active', NULL, NULL, NULL, NULL),
(114, 'KW', 'Kuwait', 'KWT', 414, 965, 'active', NULL, NULL, NULL, NULL),
(115, 'KG', 'Kyrgyzstan', 'KGZ', 417, 996, 'active', NULL, NULL, NULL, NULL),
(116, 'LA', 'Lao People\'s Democratic Republic', 'LAO', 418, 856, 'active', NULL, NULL, NULL, NULL),
(117, 'LV', 'Latvia', 'LVA', 428, 371, 'active', NULL, NULL, NULL, NULL),
(118, 'LB', 'Lebanon', 'LBN', 422, 961, 'active', NULL, NULL, NULL, NULL),
(119, 'LS', 'Lesotho', 'LSO', 426, 266, 'active', NULL, NULL, NULL, NULL),
(120, 'LR', 'Liberia', 'LBR', 430, 231, 'active', NULL, NULL, NULL, NULL),
(121, 'LY', 'Libyan Arab Jamahiriya', 'LBY', 434, 218, 'active', NULL, NULL, NULL, NULL),
(122, 'LI', 'Liechtenstein', 'LIE', 438, 423, 'active', NULL, NULL, NULL, NULL),
(123, 'LT', 'Lithuania', 'LTU', 440, 370, 'active', NULL, NULL, NULL, NULL),
(124, 'LU', 'Luxembourg', 'LUX', 442, 352, 'active', NULL, NULL, NULL, NULL),
(125, 'MO', 'Macao', 'MAC', 446, 853, 'active', NULL, NULL, NULL, NULL),
(126, 'MK', 'Macedonia, the Former Yugoslav Republic of', 'MKD', 807, 389, 'active', NULL, NULL, NULL, NULL),
(127, 'MG', 'Madagascar', 'MDG', 450, 261, 'active', NULL, NULL, NULL, NULL),
(128, 'MW', 'Malawi', 'MWI', 454, 265, 'active', NULL, NULL, NULL, NULL),
(129, 'MY', 'Malaysia', 'MYS', 458, 60, 'active', NULL, NULL, NULL, NULL),
(130, 'MV', 'Maldives', 'MDV', 462, 960, 'active', NULL, NULL, NULL, NULL),
(131, 'ML', 'Mali', 'MLI', 466, 223, 'active', NULL, NULL, NULL, NULL),
(132, 'MT', 'Malta', 'MLT', 470, 356, 'active', NULL, NULL, NULL, NULL),
(133, 'MH', 'Marshall Islands', 'MHL', 584, 692, 'active', NULL, NULL, NULL, NULL),
(134, 'MQ', 'Martinique', 'MTQ', 474, 596, 'active', NULL, NULL, NULL, NULL),
(135, 'MR', 'Mauritania', 'MRT', 478, 222, 'active', NULL, NULL, NULL, NULL),
(136, 'MU', 'Mauritius', 'MUS', 480, 230, 'active', NULL, NULL, NULL, NULL),
(137, 'YT', 'Mayotte', NULL, NULL, 269, 'active', NULL, NULL, NULL, NULL),
(138, 'MX', 'Mexico', 'MEX', 484, 52, 'active', NULL, NULL, NULL, NULL),
(139, 'FM', 'Micronesia, Federated States of', 'FSM', 583, 691, 'active', NULL, NULL, NULL, NULL),
(140, 'MD', 'Moldova, Republic of', 'MDA', 498, 373, 'active', NULL, NULL, NULL, NULL),
(141, 'MC', 'Monaco', 'MCO', 492, 377, 'active', NULL, NULL, NULL, NULL),
(142, 'MN', 'Mongolia', 'MNG', 496, 976, 'active', NULL, NULL, NULL, NULL),
(143, 'MS', 'Montserrat', 'MSR', 500, 1664, 'active', NULL, NULL, NULL, NULL),
(144, 'MA', 'Morocco', 'MAR', 504, 212, 'active', NULL, NULL, NULL, NULL),
(145, 'MZ', 'Mozambique', 'MOZ', 508, 258, 'active', NULL, NULL, NULL, NULL),
(146, 'MM', 'Myanmar', 'MMR', 104, 95, 'active', NULL, NULL, NULL, NULL),
(147, 'NA', 'Namibia', 'NAM', 516, 264, 'active', NULL, NULL, NULL, NULL),
(148, 'NR', 'Nauru', 'NRU', 520, 674, 'active', NULL, NULL, NULL, NULL),
(149, 'NP', 'Nepal', 'NPL', 524, 977, 'active', NULL, NULL, NULL, NULL),
(150, 'NL', 'Netherlands', 'NLD', 528, 31, 'active', NULL, NULL, NULL, NULL),
(151, 'AN', 'Netherlands Antilles', 'ANT', 530, 599, 'active', NULL, NULL, NULL, NULL),
(152, 'NC', 'New Caledonia', 'NCL', 540, 687, 'active', NULL, NULL, NULL, NULL),
(153, 'NZ', 'New Zealand', 'NZL', 554, 64, 'active', NULL, NULL, NULL, NULL),
(154, 'NI', 'Nicaragua', 'NIC', 558, 505, 'active', NULL, NULL, NULL, NULL),
(155, 'NE', 'Niger', 'NER', 562, 227, 'active', NULL, NULL, NULL, NULL),
(156, 'NG', 'Nigeria', 'NGA', 566, 234, 'active', NULL, NULL, NULL, NULL),
(157, 'NU', 'Niue', 'NIU', 570, 683, 'active', NULL, NULL, NULL, NULL),
(158, 'NF', 'Norfolk Island', 'NFK', 574, 672, 'active', NULL, NULL, NULL, NULL),
(159, 'MP', 'Northern Mariana Islands', 'MNP', 580, 1670, 'active', NULL, NULL, NULL, NULL),
(160, 'NO', 'Norway', 'NOR', 578, 47, 'active', NULL, NULL, NULL, NULL),
(161, 'OM', 'Oman', 'OMN', 512, 968, 'active', NULL, NULL, NULL, NULL),
(162, 'PK', 'Pakistan', 'PAK', 586, 92, 'active', NULL, NULL, NULL, NULL),
(163, 'PW', 'Palau', 'PLW', 585, 680, 'active', NULL, NULL, NULL, NULL),
(164, 'PS', 'Palestinian Territory, Occupied', NULL, NULL, 970, 'active', NULL, NULL, NULL, NULL),
(165, 'PA', 'Panama', 'PAN', 591, 507, 'active', NULL, NULL, NULL, NULL),
(166, 'PG', 'Papua New Guinea', 'PNG', 598, 675, 'active', NULL, NULL, NULL, NULL),
(167, 'PY', 'Paraguay', 'PRY', 600, 595, 'active', NULL, NULL, NULL, NULL),
(168, 'PE', 'Peru', 'PER', 604, 51, 'active', NULL, NULL, NULL, NULL),
(169, 'PH', 'Philippines', 'PHL', 608, 63, 'active', NULL, NULL, NULL, NULL),
(170, 'PN', 'Pitcairn', 'PCN', 612, 0, 'active', NULL, NULL, NULL, NULL),
(171, 'PL', 'Poland', 'POL', 616, 48, 'active', NULL, NULL, NULL, NULL),
(172, 'PT', 'Portugal', 'PRT', 620, 351, 'active', NULL, NULL, NULL, NULL),
(173, 'PR', 'Puerto Rico', 'PRI', 630, 1787, 'active', NULL, NULL, NULL, NULL),
(174, 'QA', 'Qatar', 'QAT', 634, 974, 'active', NULL, NULL, NULL, NULL),
(175, 'RE', 'Reunion', 'REU', 638, 262, 'active', NULL, NULL, NULL, NULL),
(176, 'RO', 'Romania', 'ROM', 642, 40, 'active', NULL, NULL, NULL, NULL),
(177, 'RU', 'Russian Federation', 'RUS', 643, 70, 'active', NULL, NULL, NULL, NULL),
(178, 'RW', 'Rwanda', 'RWA', 646, 250, 'active', NULL, NULL, NULL, NULL),
(179, 'SH', 'Saint Helena', 'SHN', 654, 290, 'active', NULL, NULL, NULL, NULL),
(180, 'KN', 'Saint Kitts and Nevis', 'KNA', 659, 1869, 'active', NULL, NULL, NULL, NULL),
(181, 'LC', 'Saint Lucia', 'LCA', 662, 1758, 'active', NULL, NULL, NULL, NULL),
(182, 'PM', 'Saint Pierre and Miquelon', 'SPM', 666, 508, 'active', NULL, NULL, NULL, NULL),
(183, 'VC', 'Saint Vincent and the Grenadines', 'VCT', 670, 1784, 'active', NULL, NULL, NULL, NULL),
(184, 'WS', 'Samoa', 'WSM', 882, 684, 'active', NULL, NULL, NULL, NULL),
(185, 'SM', 'San Marino', 'SMR', 674, 378, 'active', NULL, NULL, NULL, NULL),
(186, 'ST', 'Sao Tome and Principe', 'STP', 678, 239, 'active', NULL, NULL, NULL, NULL),
(187, 'SA', 'Saudi Arabia', 'SAU', 682, 966, 'active', NULL, NULL, NULL, NULL),
(188, 'SN', 'Senegal', 'SEN', 686, 221, 'active', NULL, NULL, NULL, NULL),
(189, 'CS', 'Serbia and Montenegro', NULL, NULL, 381, 'active', NULL, NULL, NULL, NULL),
(190, 'SC', 'Seychelles', 'SYC', 690, 248, 'active', NULL, NULL, NULL, NULL),
(191, 'SL', 'Sierra Leone', 'SLE', 694, 232, 'active', NULL, NULL, NULL, NULL),
(192, 'SG', 'Singapore', 'SGP', 702, 65, 'active', NULL, NULL, NULL, NULL),
(193, 'SK', 'Slovakia', 'SVK', 703, 421, 'active', NULL, NULL, NULL, NULL),
(194, 'SI', 'Slovenia', 'SVN', 705, 386, 'active', NULL, NULL, NULL, NULL),
(195, 'SB', 'Solomon Islands', 'SLB', 90, 677, 'active', NULL, NULL, NULL, NULL),
(196, 'SO', 'Somalia', 'SOM', 706, 252, 'active', NULL, NULL, NULL, NULL),
(197, 'ZA', 'South Africa', 'ZAF', 710, 27, 'active', NULL, NULL, NULL, NULL),
(198, 'GS', 'South Georgia and the South Sandwich Islands', NULL, NULL, 0, 'active', NULL, NULL, NULL, NULL),
(199, 'ES', 'Spain', 'ESP', 724, 34, 'active', NULL, NULL, NULL, NULL),
(200, 'LK', 'Sri Lanka', 'LKA', 144, 94, 'active', NULL, NULL, NULL, NULL),
(201, 'SD', 'Sudan', 'SDN', 736, 249, 'active', NULL, NULL, NULL, NULL),
(202, 'SR', 'Suriname', 'SUR', 740, 597, 'active', NULL, NULL, NULL, NULL),
(203, 'SJ', 'Svalbard and Jan Mayen', 'SJM', 744, 47, 'active', NULL, NULL, NULL, NULL),
(204, 'SZ', 'Swaziland', 'SWZ', 748, 268, 'active', NULL, NULL, NULL, NULL),
(205, 'SE', 'Sweden', 'SWE', 752, 46, 'active', NULL, NULL, NULL, NULL),
(206, 'CH', 'Switzerland', 'CHE', 756, 41, 'active', NULL, NULL, NULL, NULL),
(207, 'SY', 'Syrian Arab Republic', 'SYR', 760, 963, 'active', NULL, NULL, NULL, NULL),
(208, 'TW', 'Taiwan, Province of China', 'TWN', 158, 886, 'active', NULL, NULL, NULL, NULL),
(209, 'TJ', 'Tajikistan', 'TJK', 762, 992, 'active', NULL, NULL, NULL, NULL),
(210, 'TZ', 'Tanzania, United Republic of', 'TZA', 834, 255, 'active', NULL, NULL, NULL, NULL),
(211, 'TH', 'Thailand', 'THA', 764, 66, 'active', NULL, NULL, NULL, NULL),
(212, 'TL', 'Timor-Leste', NULL, NULL, 670, 'active', NULL, NULL, NULL, NULL),
(213, 'TG', 'Togo', 'TGO', 768, 228, 'active', NULL, NULL, NULL, NULL),
(214, 'TK', 'Tokelau', 'TKL', 772, 690, 'active', NULL, NULL, NULL, NULL),
(215, 'TO', 'Tonga', 'TON', 776, 676, 'active', NULL, NULL, NULL, NULL),
(216, 'TT', 'Trinidad and Tobago', 'TTO', 780, 1868, 'active', NULL, NULL, NULL, NULL),
(217, 'TN', 'Tunisia', 'TUN', 788, 216, 'active', NULL, NULL, NULL, NULL),
(218, 'TR', 'Turkey', 'TUR', 792, 90, 'active', NULL, NULL, NULL, NULL),
(219, 'TM', 'Turkmenistan', 'TKM', 795, 7370, 'active', NULL, NULL, NULL, NULL),
(220, 'TC', 'Turks and Caicos Islands', 'TCA', 796, 1649, 'active', NULL, NULL, NULL, NULL),
(221, 'TV', 'Tuvalu', 'TUV', 798, 688, 'active', NULL, NULL, NULL, NULL),
(222, 'UG', 'Uganda', 'UGA', 800, 256, 'active', NULL, NULL, NULL, NULL),
(223, 'UA', 'Ukraine', 'UKR', 804, 380, 'active', NULL, NULL, NULL, NULL),
(224, 'AE', 'United Arab Emirates', 'ARE', 784, 971, 'active', NULL, NULL, NULL, NULL),
(225, 'GB', 'United Kingdom', 'GBR', 826, 44, 'active', NULL, NULL, NULL, NULL),
(226, 'US', 'United States', 'USA', 840, 1, 'active', NULL, NULL, NULL, NULL),
(227, 'UM', 'United States Minor Outlying Islands', NULL, NULL, 1, 'active', NULL, NULL, NULL, NULL),
(228, 'UY', 'Uruguay', 'URY', 858, 598, 'active', NULL, NULL, NULL, NULL),
(229, 'UZ', 'Uzbekistan', 'UZB', 860, 998, 'active', NULL, NULL, NULL, NULL),
(230, 'VU', 'Vanuatu', 'VUT', 548, 678, 'active', NULL, NULL, NULL, NULL),
(231, 'VE', 'Venezuela', 'VEN', 862, 58, 'active', NULL, NULL, NULL, NULL),
(232, 'VN', 'Viet Nam', 'VNM', 704, 84, 'active', NULL, NULL, NULL, NULL),
(233, 'VG', 'Virgin Islands, British', 'VGB', 92, 1284, 'active', NULL, NULL, NULL, NULL),
(234, 'VI', 'Virgin Islands, U.s.', 'VIR', 850, 1340, 'active', NULL, NULL, NULL, NULL),
(235, 'WF', 'Wallis and Futuna', 'WLF', 876, 681, 'active', NULL, NULL, NULL, NULL),
(236, 'EH', 'Western Sahara', 'ESH', 732, 212, 'active', NULL, NULL, NULL, NULL),
(237, 'YE', 'Yemen', 'YEM', 887, 967, 'active', NULL, NULL, NULL, NULL),
(238, 'ZM', 'Zambia', 'ZMB', 894, 260, 'active', NULL, NULL, NULL, NULL),
(239, 'ZW', 'Zimbabwe', 'ZWE', 716, 263, 'active', NULL, NULL, NULL, NULL),
(240, 'IN', 'India', 'IND', 356, 91, 'active', '2018-02-20 05:52:12', 1, NULL, NULL),
(241, 'IN', 'India54', 'IND', 356, 91, 'active', '2018-02-20 05:53:05', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_degrees`
--

CREATE TABLE `masters_degrees` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('ug','pg') NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_degrees`
--

INSERT INTO `masters_degrees` (`id`, `name`, `type`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Bachelor of Arts ', 'ug', 'active', NULL, 1, NULL, NULL),
(2, 'Bachelor of Architecture', 'ug', 'active', NULL, 1, NULL, NULL),
(3, 'Bachelor of Computer Application', 'ug', 'active', NULL, 1, NULL, NULL),
(4, 'Bachelor of Business Administration', 'ug', 'active', NULL, 1, NULL, NULL),
(5, 'Bachelor of Commerce', 'ug', 'active', NULL, 1, NULL, NULL),
(6, 'Bachelor of Education', 'ug', 'active', NULL, 1, NULL, NULL),
(7, 'Bachelor of Dental Science', 'ug', 'active', NULL, 1, NULL, NULL),
(8, 'Bachelor of Hotel Management ', 'ug', 'active', NULL, 1, NULL, NULL),
(9, 'Bachelor of Pharmacy ', 'ug', 'active', NULL, 1, NULL, NULL),
(10, 'Bachelor of Science', 'ug', 'active', NULL, 1, NULL, NULL),
(11, 'Bachelor of Veterinary Science', 'ug', 'active', NULL, 1, NULL, NULL),
(12, 'Bachelor of Technology / Engineering ', 'ug', 'active', NULL, 1, NULL, NULL),
(13, 'Bachelor of Management Studies ', 'ug', 'active', NULL, 1, NULL, NULL),
(14, 'Bachelor of Law', 'ug', 'active', NULL, 1, NULL, NULL),
(15, 'Bachelor of Medicine and Bachelor of Surgery', 'ug', 'active', NULL, 1, NULL, NULL),
(16, 'Bachelor of Mass Media', 'ug', 'active', NULL, 1, NULL, NULL),
(17, 'Diploma', 'ug', 'active', NULL, 1, NULL, NULL),
(18, 'Others', 'ug', 'active', NULL, 1, NULL, NULL),
(19, 'Not Pursing Graduation', 'ug', 'active', NULL, 1, NULL, NULL),
(20, 'Chartered Accountant', 'pg', 'active', NULL, 1, NULL, NULL),
(21, 'Chartered Financial Analyst', 'pg', 'active', NULL, 1, NULL, NULL),
(22, 'Company Secretary', 'pg', 'active', NULL, 1, NULL, NULL),
(23, 'Cost Accountant', 'pg', 'active', NULL, 1, NULL, NULL),
(24, 'Master of Law', 'pg', 'active', NULL, 1, NULL, NULL),
(25, 'Master of Arts', 'pg', 'active', NULL, 1, NULL, NULL),
(26, 'Master of Architecture', 'pg', 'active', NULL, 1, NULL, NULL),
(27, 'Master of Computer Application', 'pg', 'active', NULL, 1, NULL, NULL),
(28, 'Master of Commerce', 'pg', 'active', NULL, 1, NULL, NULL),
(29, 'Master of Pharmacy ', 'pg', 'active', NULL, 1, NULL, NULL),
(30, 'Master of Science', 'pg', 'active', NULL, 1, NULL, NULL),
(31, 'Master of Veterinary Science', 'pg', 'active', NULL, 1, NULL, NULL),
(32, 'Master of Education', 'pg', 'active', NULL, 1, NULL, NULL),
(33, 'Master of Technology / Engineering ', 'pg', 'active', NULL, 1, NULL, NULL),
(34, 'Master of Business Administration / Post Graduate Diploma in Management ', 'pg', 'active', NULL, 1, NULL, NULL),
(35, 'Medical', 'pg', 'active', NULL, 1, NULL, NULL),
(36, 'PG Diploma', 'pg', 'active', NULL, 1, NULL, NULL),
(37, 'Ph.D / Doctorate', 'pg', 'active', NULL, 1, NULL, NULL),
(38, 'Master of Philosophy', 'pg', 'active', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_designations`
--

CREATE TABLE `masters_designations` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_designations`
--

INSERT INTO `masters_designations` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Trainee', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(2, 'Junior Officer', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(3, 'Officer', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(4, 'Senior Officer', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(5, 'Junior Executive', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(6, 'Executive', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(7, 'Senior Executive', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(8, 'Assistant Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(9, 'Deputy Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(10, 'Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(11, 'Senior Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(12, 'Chief Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(13, 'Assistant General Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(14, 'Deputy General Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(15, 'General Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(16, 'Senior General Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(17, 'Chief General Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(18, 'Assistant Vice President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(19, 'Deputy Vice President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(20, 'Vice President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(21, 'Deputy President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(22, 'President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(23, 'Executive President', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(24, 'Director', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(25, 'Assistant Director', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(26, 'Executive Director', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(27, 'Vice Chairman', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(28, 'Chairman', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(29, 'Managing Director', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(30, 'Others', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(31, 'Junior Analyst', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(32, 'Analyst', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(33, 'Senior Analyst', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(34, 'Junior Associate', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(35, 'Associate', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(36, 'Senior Associate', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(37, 'CEO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(38, 'COO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(39, 'Partner', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(40, 'CHRO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(41, 'CFO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(42, 'CMO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(43, 'Consultant', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(44, 'Associate Consultant', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(45, 'Senior Consultant', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(46, 'CTO', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(47, 'Software / System Engineer / Developer', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(48, 'Senior Software / System Engineer / Developer', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(49, 'Technical Lead', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(50, 'Team Lead', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(51, 'Project Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(52, 'Software Architect', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(53, 'Program Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(54, 'Delivery Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(55, 'Business Analyst', 'active', '2018-01-30 18:58:36', 1, NULL, NULL),
(56, 'Engineering Manager', 'active', '2018-01-30 18:58:36', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_email_templates`
--

CREATE TABLE `masters_email_templates` (
  `id` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `slug` varchar(100) NOT NULL,
  `subject` varchar(100) NOT NULL,
  `body` text NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `masters_email_templates`
--

INSERT INTO `masters_email_templates` (`id`, `name`, `slug`, `subject`, `body`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Account Activation', 'account-activation', 'Account Activation', '<html>\r\n    <head>\r\n        <meta name=\"viewport\" content=\"width=device-width\" />\r\n        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n        <title> Notification</title>\r\n       \r\n    </head>\r\n    <body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n        <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n            <tr>\r\n                <td>&nbsp;</td>\r\n                <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                    <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\" >\r\n\r\n                        <!-- START CENTERED WHITE CONTAINER -->\r\n                        <span class=\"preheader\"></span>\r\n                        <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                            <!-- START MAIN CONTENT AREA -->\r\n                            <tr>\r\n                                <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n										<tr>\r\n											<td>\r\n												<p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n												<p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">To activate your account, please click on the below link.</p>\r\n												<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n													<tbody>\r\n														<tr>\r\n															<td align=\"center\">\r\n																<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n																	<tbody>\r\n																		<tr>\r\n																			<td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{ACCOUNT_ACTIVATION_LINK}\" target=\"_blank\">Activate your account</a> </td>\r\n																		</tr>\r\n																	</tbody>\r\n																</table>\r\n															</td>\r\n														</tr>\r\n													</tbody>\r\n												</table>\r\n											</td>\r\n										</tr>\r\n									</table>\r\n                                </td>\r\n                            </tr>\r\n\r\n                            <!-- END MAIN CONTENT AREA -->\r\n                        </table>\r\n\r\n                        <!-- START FOOTER -->\r\n                      <!--   <div class=\"footer\">\r\n                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                <tr>\r\n                                    <td class=\"content-block\">\r\n                                        <span class=\"apple-link\"></span>\r\n                                    </td>\r\n                                </tr>\r\n                            </table>\r\n                        </div> -->\r\n                        <!-- END FOOTER -->\r\n\r\n                        <!-- END CENTERED WHITE CONTAINER -->\r\n                    </div>\r\n                </td>\r\n                <td>&nbsp;</td>\r\n            </tr>\r\n        </table>\r\n    </body>\r\n</html>', 'active', '2018-01-14 13:19:29', 1, '2018-02-02 05:36:03', 1),
(2, 'Account Activation Success', 'account-activation-success', 'Account Activation Success', '<html>\r\n    <head>\r\n        <meta name=\"viewport\" content=\"width=device-width\" />\r\n        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n        <title>Notification</title>        \r\n\r\n    </head>\r\n    <body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n         <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n            <tr>\r\n                <td>&nbsp;</td>\r\n                <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                    <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\" >\r\n\r\n                        <!-- START CENTERED WHITE CONTAINER -->\r\n                        <span class=\"preheader\"></span>\r\n                        <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                            <!-- START MAIN CONTENT AREA -->\r\n                            <tr>\r\n                                <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                        <tr>\r\n                                            <td>\r\n												<p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n												<p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Congratulation! Your account is successfully activated.</p>\r\n												<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n													<tbody>\r\n														<tr>\r\n															<td align=\"center\">\r\n																<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n																	<tbody>\r\n																		<tr>\r\n																			<td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{LOGIN_LINK}\" target=\"_blank\">Login to your account</a> </td>\r\n																		</tr>\r\n																	</tbody>\r\n																</table>\r\n															</td>\r\n														</tr>\r\n													</tbody>\r\n												</table>\r\n											</td>\r\n										</tr>\r\n									</table>\r\n                                </td>\r\n                            </tr>\r\n\r\n                            <!-- END MAIN CONTENT AREA -->\r\n                        </table>\r\n\r\n                        <!-- START FOOTER -->\r\n                       <!--  <div class=\"footer\">\r\n                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                <tr>\r\n                                    <td class=\"content-block\">\r\n                                        <span class=\"apple-link\"></span>\r\n                                    </td>\r\n                                </tr>\r\n                            </table>\r\n                        </div> -->\r\n                        <!-- END FOOTER -->\r\n\r\n                        <!-- END CENTERED WHITE CONTAINER -->\r\n                    </div>\r\n                </td>\r\n                <td>&nbsp;</td>\r\n            </tr>\r\n        </table>\r\n    </body>\r\n</html>', 'active', '2018-01-14 13:19:29', 1, '2018-02-02 05:36:54', 1),
(3, 'Reset Password', 'reset-password', 'Reset Password', '<html>\r\n <head>\r\n <meta name=\"viewport\" content=\"width=device-width\" />\r\n <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n <title>Notification</title>\r\n </head>\r\n <body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n         <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n            <tr>\r\n                <td>&nbsp;</td>\r\n                <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                    <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\" >\r\n\r\n                        <!-- START CENTERED WHITE CONTAINER -->\r\n                        <span class=\"preheader\"></span>\r\n                        <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                            <!-- START MAIN CONTENT AREA -->\r\n                            <tr>\r\n                                <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                        <tr>\r\n                                            <td>\r\n <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">To reset your account password, please click on the below link.</p>\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n <tbody>\r\n <tr>\r\n <td align=\"center\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tbody>\r\n <tr>\r\n <td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{RESET_PASSWORD_LINK}\" target=\"_blank\">Reset your account password</a> </td>\r\n </tr>\r\n </tbody>\r\n </table>\r\n </td>\r\n </tr>\r\n </tbody>\r\n </table>\r\n </td>\r\n </tr>\r\n </table>\r\n </td>\r\n </tr>\r\n\r\n <!-- END MAIN CONTENT AREA -->\r\n </table>\r\n\r\n <!-- START FOOTER -->\r\n<!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\"></span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n <!-- END FOOTER -->\r\n\r\n <!-- END CENTERED WHITE CONTAINER -->\r\n </div>\r\n </td>\r\n <td>&nbsp;</td>\r\n </tr>\r\n </table>\r\n </body>\r\n</html>', 'active', '2018-01-14 13:19:29', 1, '2018-02-02 05:37:19', 1),
(4, 'Candidate Applied For Job', 'candidate-applied-for-job', 'Candidate has been applied for job', '<p></p>\r\n<table class=\"body\" border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">\r\n<tbody>\r\n<tr>\r\n<td>&nbsp;</td>\r\n<td class=\"container\" style=\"display: block; margin: 0 auto !important; max-width: 580px; padding: 10px; width: 580px;\">\r\n<div class=\"content\" style=\"box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;\"><!-- START CENTERED WHITE CONTAINER -->\r\n<table class=\"main\" style=\"background: #ffffff; border-radius: 3px; width: 100%;\"><!-- START MAIN CONTENT AREA -->\r\n<tbody>\r\n<tr>\r\n<td class=\"wrapper\" style=\"box-sizing: border-box; padding: 20px;\">\r\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\r\n<tbody>\r\n<tr>\r\n<td>\r\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">Hello {USER_HR_FULLNAME},</p>\r\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{USER_FULLNAME} applied for job {JOB_TITLE}.</p>\r\n\r\n</td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n</td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n</td>\r\n</tr>\r\n<!-- END MAIN CONTENT AREA --></tbody>\r\n</table>\r\n<!-- START FOOTER --> <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\">RecPro</span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> --> <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --></div>\r\n</td>\r\n<td>&nbsp;</td>\r\n</tr>\r\n</tbody>\r\n</table>', 'active', NULL, 1, '2018-03-30 12:06:16', 1),
(5, 'Send Job', 'send-job', 'Job - {JOB_TITLE}', '<p></p>\n<table class=\"body\" border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr>\n<td>&nbsp;</td>\n<td class=\"container\" style=\"display: block; margin: 0 auto !important; max-width: 580px; padding: 10px; width: 580px;\">\n<div class=\"content\" style=\"box-sizing: border-box; display: block; margin: 0 auto; max-width: 580px; padding: 10px;\"><!-- START CENTERED WHITE CONTAINER -->\n<table class=\"main\" style=\"background: #ffffff; border-radius: 3px; width: 100%;\"><!-- START MAIN CONTENT AREA -->\n<tbody>\n<tr>\n<td class=\"wrapper\" style=\"box-sizing: border-box; padding: 20px;\">\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">Hello {USER_FULLNAME},</p>\n<table class=\"btn btn-primary\" border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr>\n<td align=\"center\">\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n<tbody>\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Experience required for Job</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_WORK_EXP_MIN} - {JOB_WORK_EXP_MAX} Years</p>\n</td>\n</tr>\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Annual Salary of the Job</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_ANNUAL_CTC_MIN} - {JOB_ANNUAL_CTC_MAX} Lacs</p>\n</td>\n</tr>\n<tr>\n<td>&nbsp;</td>\n<td><a style=\"background-color: #3498db; border-color: #3498db; color: #ffffff; border: solid 1px #3498db; border-radius: 5px; box-sizing: border-box; cursor: pointer; display: inline-block; font-size: 14px; font-weight: bold; margin: 0; padding: 12px 25px; text-decoration: none; text-transform: capitalize;\" href=\"{APPLY_LINK}\" target=\"_blank\" rel=\"noopener\">Apply Now</a></td>\n</tr>\n<tr>\n<td><br />\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Organization</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_ORGANIZATION}</p>\n</td>\n</tr>\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Designation</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_ROLE}</p>\n</td>\n</tr>\n<!-- <tr>\n                                                                        <td>\n                                                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: bold;margin: 0;Margin-bottom: 15px; \">Qualification </p>\n                                                                        </td>\n                                                                        <td>\n                                                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \"></p>\n                                                                        </td>\n                                                                    </tr> -->\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Experience</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_WORK_EXP_MIN} - {JOB_WORK_EXP_MAX} Years</p>\n</td>\n</tr>\n<tr>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: bold; margin: 0; margin-bottom: 15px;\">Key Skills</p>\n</td>\n<td>\n<p style=\"font-family: sans-serif; font-size: 14px; font-weight: normal; margin: 0; margin-bottom: 15px;\">{JOB_KEYWORDS}</p>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n</tbody>\n</table>\n</td>\n</tr>\n<!-- END MAIN CONTENT AREA --></tbody>\n</table>\n<!-- START FOOTER --> <!--  <div class=\"footer\">\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\n <tr>\n <td class=\"content-block\">\n <span class=\"apple-link\">RecPro</span>\n </td>\n </tr>\n </table>\n </div> --> <!-- END FOOTER --> <!-- END CENTERED WHITE CONTAINER --></div>\n</td>\n<td>&nbsp;</td>\n</tr>\n</tbody>\n</table>', 'active', NULL, 1, '2018-02-16 10:58:10', 1),
(6, 'Schedule Interview For Candidate', 'schedule-interview-candidate', 'Interview Scheduled - {JOB_TITLE}', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Your interview for job {JOB_TITLE} , round number {ROUND_NUMBER} is scheduled by {USER_COMPANY_FIRSTNAME} {USER_COMPANY_LASTNAME}</p>\r\n                                         <!--    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n                                                <tbody>\r\n                                                    <tr>\r\n                                                        <td align=\"center\">\r\n                                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                                                <tbody>\r\n                                                                    <tr>\r\n                                                                        <td>\r\n                                                                            <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\"\r\n                                                                                href=\"#\" target=\"_blank\">Confirm</a>\r\n                                                                        </td>\r\n                                                                    </tr>\r\n                                                                </tbody>\r\n                                                            </table>\r\n                                                        </td>\r\n                                                    </tr>\r\n                                                </tbody>\r\n                                            </table> -->\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\"></span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, 1, NULL, NULL),
(7, 'Interview Scheduled', 'schedule-interview-interviewer', 'Interview Scheduled', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {INTERVIEWER_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">An interview has been scheduled for candidate {USER_FULLNAME} for job {JOB_TITLE} </p>\r\n                                            <!-- <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n                                                <tbody>\r\n                                                    <tr>\r\n                                                        <td align=\"center\">\r\n                                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                                                <tbody>\r\n                                                                    <tr>\r\n                                                                        <td>\r\n                                                                            <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\"\r\n                                                                                href=\"#\" target=\"_blank\">Confirm</a>\r\n                                                                        </td>\r\n                                                                    </tr>\r\n                                                                </tbody>\r\n                                                            </table>\r\n                                                        </td>\r\n                                                    </tr>\r\n                                                </tbody>\r\n                                            </table> -->\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\"></span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, NULL, NULL, NULL),
(8, 'Candidate Result', 'candidate-result', 'Candidate Result for Job {JOB_TITLE}', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_HR_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Candidate {USER_FULLNAME} has been {STATUS}ed for round number {ROUND_NUMBER} for job {JOB_TITLE}</p>\r\n                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n                                                <tbody>\r\n                                                    <tr>\r\n                                                        <td align=\"center\">\r\n                                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                                                <tbody>\r\n                                                                    <tr>\r\n                                                                        <td>\r\n                                                                            <!-- <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\"\r\n                                                                                 target=\"_blank\">Thank You</a> -->\r\n                                                                        </td>\r\n                                                                    </tr>\r\n                                                                </tbody>\r\n                                                            </table>\r\n                                                        </td>\r\n                                                    </tr>\r\n                                                </tbody>\r\n                                            </table>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\"></span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, NULL, NULL, NULL),
(9, 'Account Creation', 'account-creation', 'Account Created', '<html>\r\n    <head>\r\n        <meta name=\"viewport\" content=\"width=device-width\" />\r\n        <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n        <title> Notification</title>\r\n       \r\n    </head>\r\n    <body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n        <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n            <tr>\r\n                <td>&nbsp;</td>\r\n                <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                    <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\" >\r\n\r\n                        <!-- START CENTERED WHITE CONTAINER -->\r\n                        <span class=\"preheader\"></span>\r\n                        <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                            <!-- START MAIN CONTENT AREA -->\r\n                            <tr>\r\n                                <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n										<tr>\r\n											<td>\r\n                                                <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n                                                <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Your account has been created successfully.</p>\r\n												<!-- <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">To activate your account, please click on the below link.</p>\r\n												<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n													<tbody>\r\n														<tr>\r\n															<td align=\"center\">\r\n																<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n																	<tbody>\r\n																		<tr>\r\n																			<td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{ACCOUNT_ACTIVATION_LINK}\" target=\"_blank\">Activate your account</a> </td>\r\n																		</tr>\r\n																	</tbody>\r\n																</table>\r\n															</td>\r\n														</tr>\r\n													</tbody>\r\n												</table> -->\r\n											</td>\r\n										</tr>\r\n									</table>\r\n                                </td>\r\n                            </tr>\r\n\r\n                            <!-- END MAIN CONTENT AREA -->\r\n                        </table>\r\n\r\n                        <!-- START FOOTER -->\r\n                      <!--   <div class=\"footer\">\r\n                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                <tr>\r\n                                    <td class=\"content-block\">\r\n                                        <span class=\"apple-link\">RecPro</span>\r\n                                    </td>\r\n                                </tr>\r\n                            </table>\r\n                        </div> -->\r\n                        <!-- END FOOTER -->\r\n\r\n                        <!-- END CENTERED WHITE CONTAINER -->\r\n                    </div>\r\n                </td>\r\n                <td>&nbsp;</td>\r\n            </tr>\r\n        </table>\r\n    </body>\r\n</html>', 'active', NULL, 1, NULL, NULL),
(10, 'Set Password', 'set-password', 'Password Set', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {USER_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Your password set to {USER_PASSWORD} successfully.</p>\r\n                                            <!--  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n <tbody>\r\n <tr>\r\n <td align=\"center\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tbody>\r\n <tr>\r\n <td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{RESET_PASSWORD_LINK}\" target=\"_blank\">Reset your account password</a> </td>\r\n </tr>\r\n </tbody>\r\n </table>\r\n </td>\r\n </tr>\r\n </tbody>\r\n </table> -->\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\">RecPro</span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, 1, NULL, NULL),
(11, 'Assign Hr - Create Job', 'assign-hr-create-job', 'Job {JOB_TITLE} is assigned to you', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {HR_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Job \"{JOB_TITLE}\" is assigned to u.</p>\r\n                                            <!--  <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\" style=\"background-color: #3498db; \">\r\n <tbody>\r\n <tr>\r\n <td align=\"center\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tbody>\r\n <tr>\r\n <td> <a style=\"background-color: #3498db;border-color: #3498db;color: #ffffff;border: solid 1px #3498db;border-radius: 5px;box-sizing: border-box;cursor: pointer;display: inline-block;font-size: 14px;font-weight: bold;margin: 0;padding: 12px 25px;text-decoration: none;text-transform: capitalize;\" href=\"{RESET_PASSWORD_LINK}\" target=\"_blank\">Reset your account password</a> </td>\r\n </tr>\r\n </tbody>\r\n </table>\r\n </td>\r\n </tr>\r\n </tbody>\r\n </table> -->\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\">RecPro</span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, NULL, NULL, NULL),
(12, 'Assign Hr - Schedule Interview', 'assign-hr-schedule-interview', 'Notification - Interview Scheduled ', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {HR_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Interview has been scheduled for Job \"{JOB_TITLE}\" round number {ROUND_NUMBER}.</p>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', NULL, NULL, NULL, NULL),
(13, 'Pending Shortlisting', 'pending-shortlist', 'Pending Shortlisting', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {HR_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Candidate {CANDIDATE_NAME} is pending for shortlisting for Job {JOB_TITLE}.</p>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', '2018-03-20 00:00:00', NULL, NULL, NULL),
(14, 'Skip Shortlisting', 'skip-shortlist', 'Skip Shortlisting', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {HR_FULLNAME},</p>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Candidate {CANDIDATE_NAME} is skipped for shortlisting of Job {JOB_TITLE} by {USER_FULLNAME}</p>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', '2018-03-27 00:00:00', NULL, NULL, NULL);
INSERT INTO `masters_email_templates` (`id`, `name`, `slug`, `subject`, `body`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(15, 'Candidate Interested for job {JOB_TITLE}', 'candidate-interested-for-job', 'Candidate Interested For Job {JOB_TITLE}', '<html>\r\n\r\n<head>\r\n    <meta name=\"viewport\" content=\"width=device-width\" />\r\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\r\n    <title>Notification</title>\r\n</head>\r\n\r\n<body style=\" background-color: #f6f6f6;font-family: sans-serif;font-size: 14px;margin: 0;padding: 0;width: 100%;\">\r\n    <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"body\" width=\"100%\">\r\n        <tr>\r\n            <td>&nbsp;</td>\r\n            <td class=\"container\" style=\"display: block;Margin: 0 auto !important;max-width: 580px;padding: 10px;width: 580px;\">\r\n                <div class=\"content\" style=\"box-sizing: border-box;display: block;Margin: 0 auto;max-width: 580px;padding: 10px;\">\r\n\r\n                    <!-- START CENTERED WHITE CONTAINER -->\r\n                    <span class=\"preheader\"></span>\r\n                    <table class=\"main\" style=\"background: #ffffff;border-radius: 3px;width: 100%;\">\r\n\r\n                        <!-- START MAIN CONTENT AREA -->\r\n                        <tr>\r\n                            <td class=\"wrapper\" style=\"box-sizing: border-box;\r\n    padding: 20px;\">\r\n                                <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                    <tr>\r\n                                        <td>\r\n                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Hello {HR_FULLNAME},</p>\r\n                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"btn btn-primary\">\r\n                                                <tbody>\r\n                                                    <tr>\r\n                                                        <td align=\"center\">\r\n                                                            <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n                                                                <tbody>\r\n                                                                    <tr>\r\n                                                                        <td>\r\n                                                                            <p style=\" font-family: sans-serif;font-size: 14px;font-weight: bold;margin: 0;Margin-bottom: 15px; \">Candidate {USER_FULLNAME} interested for Job \"{JOB_TITLE}\" </p>\r\n                                                                            <br>\r\n                                                                               <p style=\" font-family: sans-serif;font-size: 14px;font-weight: normal;margin: 0;Margin-bottom: 15px; \">Please tag candidate {USER_FULLNAME} against Job {JOB_TITLE}</p>\r\n                                                                        </td>\r\n                                                                    </tr>\r\n                                                                </tbody>\r\n                                                            </table>\r\n                                                        </td>\r\n                                                    </tr>\r\n                                                </tbody>\r\n                                            </table>\r\n                                        </td>\r\n                                    </tr>\r\n                                </table>\r\n                            </td>\r\n                        </tr>\r\n\r\n                        <!-- END MAIN CONTENT AREA -->\r\n                    </table>\r\n\r\n                    <!-- START FOOTER -->\r\n                    <!--  <div class=\"footer\">\r\n <table border=\"0\" cellpadding=\"0\" cellspacing=\"0\">\r\n <tr>\r\n <td class=\"content-block\">\r\n <span class=\"apple-link\">RecPro</span>\r\n </td>\r\n </tr>\r\n </table>\r\n </div> -->\r\n                    <!-- END FOOTER -->\r\n\r\n                    <!-- END CENTERED WHITE CONTAINER -->\r\n                </div>\r\n            </td>\r\n            <td>&nbsp;</td>\r\n        </tr>\r\n    </table>\r\n</body>\r\n\r\n</html>', 'active', '2018-03-29 00:00:00', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_functional_areas`
--

CREATE TABLE `masters_functional_areas` (
  `id` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `masters_functional_areas`
--

INSERT INTO `masters_functional_areas` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Accounts', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(2, 'Cost Accounting', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(3, 'Direct Tax', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(4, 'Indirect Tax', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(5, 'Credit Control', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(6, 'Investor Relations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(7, 'Statutory Audit', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(8, 'Internal Audit', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(9, 'Treasury', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(10, 'Budgeting', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(11, 'Financial Planning and Analysis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(12, 'Finance Controller', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(13, 'Regulatory Affairs', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(14, 'Compliance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(15, 'Fundraising', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(16, 'Reservations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(17, 'Tour Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(18, 'Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(19, 'Business Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(20, 'Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(21, 'Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(22, 'Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(23, 'Cabin Crew', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(24, 'Ground Staff', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(25, 'Aviation Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(26, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(27, 'Data Analysis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(28, 'Product Analysis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(29, 'Business Analysis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(30, 'Financial Analysis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(31, 'Anchor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(32, 'Compiler', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(33, 'Correspondent / Reporter', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(34, 'Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(35, 'Spot Boy', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(36, 'Animation / Graphic Artist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(37, 'Stunt Coordination', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(38, 'Wardrobe / Make up / Hair Artist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(39, 'AV Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(40, 'Visualiser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(41, 'Sound Mixer / Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(42, 'Locations Manager', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(43, 'Lighting Technology', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(44, 'Special Effects', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(45, 'Photographer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(46, 'Cameraman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(47, 'Choreographer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(48, 'Music Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(49, 'Cinematographer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(50, 'Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(51, 'Producer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(52, 'Architect', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(53, 'Draughtsman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(54, 'Project Architect', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(55, 'Naval Architect', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(56, 'Landscape Architect', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(57, 'Town Planner', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(58, 'Interior Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(59, 'Art Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(60, 'Visualiser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(61, 'Web Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(62, 'Copywriter', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(63, 'Graphic Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(64, 'Creative Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(65, 'Commercial Artist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(66, 'Customer Service', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(67, 'Collections', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(68, 'CRM / Phone / Internet Banking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(69, 'Retail Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(70, 'Agency Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(71, 'Direct Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(72, 'Bancassurance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(73, 'Group Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(74, 'Corporate / Institutional Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(75, 'Credit', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(76, 'Asset Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(77, 'Private Banking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(78, 'Product Manager Liabilities', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(79, 'Product Manager Assets', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(80, 'Merchant Acquisition', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(81, 'Business Alliances', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(82, 'Back office', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(83, 'Money Market Dealer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(84, 'Forex Dealer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(85, 'Forex Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(86, 'Forex Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(87, 'Debt Dealer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(88, 'Debt Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(89, 'Debt Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(90, 'Derivative Dealer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(91, 'Derivative Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(92, 'Derivative Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(93, 'Treasury Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(94, 'Depository Services', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(95, 'Compliance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(96, 'Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(97, 'Trade Finance Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(98, 'Technology Manager', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(99, 'KAM / RM', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(100, 'Credit', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(101, 'Debt', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(102, 'Mergers and Acquisitions', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(103, 'Equity', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(104, 'Domestic Debt', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(105, 'Offshore Debt', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(106, 'Project Finance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(107, 'IPO', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(108, 'Actuary', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(109, 'Medical Underwriting', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(110, 'Financial Underwriting', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(111, 'Claims', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(112, 'Fund Manager Debt', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(113, 'Fund Manager Equity', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(114, 'Private Equity', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(115, 'Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(116, 'Freelance Journalist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(117, 'Business Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(118, 'Fashion Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(119, 'Features Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(120, 'International Business Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(121, 'IT / Technical Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(122, 'Sports Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(123, 'Political Content Developer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(124, 'Journalist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(125, 'Editor / Reporter / Correspondent', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(126, 'Investigative Journalism', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(127, 'Proof Reading', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(128, 'Business Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(129, 'Fashion Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(130, 'Features Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(131, 'International Business Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(132, 'IT / Technical Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(133, 'Sports Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(134, 'Political Editor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(135, 'Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(136, 'Corporate Planning / Strategy', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(137, 'Research Associate', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(139, 'EA to Chairman / President / VP', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(140, 'CEO / MD / Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(141, 'VP / President', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(142, 'Partner', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(143, 'Documentation / Shipping', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(144, 'Production', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(145, 'Merchandiser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(146, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(147, 'Business Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(148, 'Liasoning', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(149, 'Accessory Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(150, 'Apparel / Garment Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(151, 'Footwear Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(152, 'Merchandiser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(153, 'Textile Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(154, 'Jewellery Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(155, 'Stenographer / Data Entry Operator', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(156, 'Receptionist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(157, 'Secretary / PA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(158, 'Bartender', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(159, 'Commis', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(160, 'Steward', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(161, 'Captain', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(162, 'Host / Hostess', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(163, 'Butler', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(164, 'Chef de partie', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(165, 'Executive Sous Chef / Chef De Cuisine', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(166, 'Sous Chef', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(167, 'Banquet Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(168, 'Restaurant Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(169, 'F&B Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(170, 'General Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(171, 'Housekeeping', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(172, 'Cashier', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(173, 'Front Office / Guest Relations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(174, 'Travel Desk', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(175, 'Lobby / Duty Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(176, 'Recruitment / Talent Acquisition', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(177, 'Payroll', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(178, 'Compensations and Benefits', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(179, 'Performance Management (PMS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(180, 'Industrial / Labour Relations Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(181, 'Training', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(182, 'Learning & Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(183, 'Organisational Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(184, 'Manpower Planning', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(185, 'HR Business Partner', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(186, 'Employee Relations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(187, 'Administration', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(188, 'Facility Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(189, 'Overall HR', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(190, 'Voice - Technical', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(191, 'Non Voice - Technical', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(192, 'Voice - Non Technical', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(193, 'Non Voice - Non Technical', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(194, 'Process Flow', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(195, 'Business Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(196, 'Transition / Migration', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(197, 'Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(198, 'Dialer Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(199, 'Technical / Process Trainer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(200, 'Voice & Accent Trainer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(201, 'Soft Skills Trainer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(202, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(203, 'Medical Transcription', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(204, 'Apprentice / Intern', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(205, 'Private Attorney / Lawyer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(206, 'Advisor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(207, 'Law Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(208, 'Company Secretary', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(209, 'Drug Regulatory', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(210, 'Drug Documentation / Medical Writing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(211, 'Regulatory Affairs', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(212, 'Clinical Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(213, 'Analytical Chemistry', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(214, 'Chemical Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(215, 'Bio / Pharma Informatics', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(216, 'Formulation Scientist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(217, 'Microbiologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(218, 'Molecular Biology', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(219, 'Nutritionist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(220, 'Research Scientist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(221, 'BioTech Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(222, 'Pharmacist / Chemist / Biochemist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(223, 'Bio-Statistician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(224, 'Chief Medical Officer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(225, 'Lab Technician / Medical Technician / Lab Staff', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(226, 'Medical Officer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(227, 'Nurse', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(228, 'Medical Superintendent / Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(229, 'Anaesthetist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(230, 'Cardiologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(231, 'Dermatologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(232, 'Dietician / Nutritionist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(233, 'ENT Specialist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(234, 'General Practitioner', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(235, 'Gynaecologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(236, 'Hepatologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(237, 'Microbiologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(238, 'Nephrologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(239, 'Neurologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(240, 'Oncologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(241, 'Opthamologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(242, 'Orthopaedist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(243, 'Paramedic', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(244, 'Pathologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(245, 'Pediatrician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(246, 'Physiotherapist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(247, 'Psychiatrist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(248, 'Radiologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(249, 'Surgeon', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(250, 'Medical Representative', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(251, 'Client Servicing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(252, 'Account Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(253, 'Creative Director', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(254, 'Media Buying', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(255, 'Media Planning', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(256, 'Events / Promotion', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(257, 'Corporate Communication', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(258, 'Direct Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(259, 'Product / Brand Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(260, 'Business Alliances', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(261, 'Regional / Zonal Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(262, 'Retail Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(263, 'Rural Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(264, 'International Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(265, 'Internal Communications', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(266, 'Market Research / Consumer Insights', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(267, 'Trade Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(268, 'PR & Media Relations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(269, 'SEM Specialist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(270, 'SEO Specialist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(271, 'Affiliate Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(272, 'Email Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(273, 'PPC Specialist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(274, 'Social Media Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(275, 'Display Marketing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(276, 'Packaging Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(277, 'Scientist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(278, 'Industrial Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(279, 'Design Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(280, 'Factory Head', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(281, 'Engineering', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(282, 'Production', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(283, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(284, 'Product Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(285, 'Workman / Foreman / Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(286, 'Service / Maintenance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(287, 'Project Mgr - Production / Manufacturing / Maintenance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(288, 'Safety Officer / Manager', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(289, 'Environment Engineer / Officer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(290, 'Health Officer / Manager', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(291, 'Project Manager Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(292, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(293, 'Project Mgr - Production / Manufacturing / Maintenance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(294, 'Civil Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(295, 'Civil Engineer Municipal', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(296, 'Civil Engineer Water / Wastewater', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(297, 'Civil Engineer Land Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(298, 'Civil Engineer Aviation', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(299, 'Civil Engineer Highway Roadway', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(300, 'Civil Engineer Traffic', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(301, 'Civil Engineer Other', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(302, 'Electronic Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(303, 'Electronic Engineer Commercial', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(304, 'Electronic Engineer Industrial', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(305, 'Electronic Engineer Utility', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(306, 'Electronic Engineer Others', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(307, 'Geotechnical Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(308, 'Mechanical Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(309, 'Mechanical Engineer HVAC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(310, 'Mechanical Engineer Plumbing / Fire Protection', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(311, 'Mechanical Engineer Others', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(312, 'Process Engineer Plant Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(313, 'Structural Engineer Bridge', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(314, 'Structural Engineer Building', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(315, 'Structural Engineer Other', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(316, 'Geographic Information System GIS', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(317, 'Construction - General Building', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(318, 'Construction - Heavy', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(319, 'Construction - Residential', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(320, 'Construction - Speciality', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(321, 'Construction - Construction Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(322, 'Construction - Others', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(323, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(324, 'Engineer - Other', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(325, 'Store Keeper / Warehouse Assistant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(326, 'Warehouse Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(327, 'Clearing Forwarding Agent', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(328, 'Logistics', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(329, 'Transport / Distribution', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(330, 'Purchase', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(331, 'Vendor Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(332, 'Material Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(333, 'Commercial Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(334, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(335, 'Commodity Trading', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(336, 'R&D', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(337, 'Clinical Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(338, 'Analytical Chemistry', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(339, 'Chemical Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(340, 'Bio/Pharma Informatics', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(341, 'Formulation Scientist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(342, 'Microbiologist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(343, 'Molecular Biology', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(344, 'Nutritionist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(345, 'Research Scientist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(346, 'BioTech Research', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(347, 'Pharmacist / Chemist / Biochemist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(348, 'Bio-Statistician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(349, 'Lab Technician / Medical Technician / Lab Staff', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(350, 'Product Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(351, 'Drug Regulatory', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(352, 'Drug Documentation / Medical Writing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(353, 'Regulatory Affairs', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(354, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(355, 'Design Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(356, 'Field Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(357, 'Counter Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(358, 'Medical Representative', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(359, 'Merchandiser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(360, 'Business Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(361, 'Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(362, 'Client Servicing / KAM', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(363, 'Banquet Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(364, 'Institutional Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(365, 'Sales', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(366, 'Client Relationship Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(367, 'Key Account Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(368, 'Sales Trainer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(369, 'Sales Promotion', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(370, 'Proposal Response Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(371, 'Bid Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(372, 'Collateral Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(373, 'RFI / RFP Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(374, 'Pre Sales Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(375, 'Post Sales Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(376, 'Service / Maintenance', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(377, 'Security Guard / Supervisor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(378, 'Police Man', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(379, 'Army / Navy / Air Force Personnel', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(380, 'Security Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(381, 'Deck Staff', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(382, 'Marine Captain / Master Mariner', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(383, 'Ship Captain', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(384, 'Cabin Crew', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(385, 'Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(386, 'Seaman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(387, 'Able Seaman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(388, 'Ordinary Seaman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(389, 'Electro Technical Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(390, 'Electrical Officer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(391, 'Radio Officer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(392, 'General Engineering', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(393, 'Electrical Engineering', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(394, 'Gas Engineering', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(395, 'Reefer Engineering', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(396, '2nd Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(397, '3rd Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(398, '4th Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(399, '5th Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(400, 'Mechanic / Machinist / Motorman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(401, 'Pumpman', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(402, 'Crane Operations', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(403, 'Deck Filter / Oilers', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(404, 'Engine Fitter', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(405, 'Steward', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(406, 'Laundry Man', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(407, 'Bosun', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(408, 'Wiper', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(409, 'Cook', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(410, 'Chef', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(411, 'Sous Chef', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(412, 'Bartender', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(413, 'Musician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(414, 'Purser', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(415, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(416, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(417, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(418, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(419, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(420, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(421, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(422, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(423, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(424, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(425, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(426, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(427, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(428, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(429, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(430, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(431, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(432, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(433, 'Business Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(434, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(435, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(436, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(438, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(439, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(440, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(441, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(442, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(443, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(444, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(445, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(446, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(447, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(448, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(449, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(450, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(451, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(452, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(453, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(454, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(455, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(456, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(457, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(458, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(459, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(460, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(462, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(463, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(464, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(466, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(467, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(468, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(469, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(470, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(471, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(472, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(473, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(474, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(475, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(476, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(477, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(478, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(479, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(480, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(481, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(482, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(483, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(484, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(485, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(486, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(487, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(488, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(490, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(491, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(492, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(494, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(495, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(496, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(497, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(498, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(499, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(500, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(501, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(502, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(503, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(504, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(505, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(506, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(507, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(508, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(509, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(510, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(511, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(512, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(513, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(514, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(515, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(516, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(518, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(519, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(520, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(522, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(523, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(524, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(525, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(526, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(527, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(528, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(529, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(530, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(531, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(532, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(533, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(534, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(535, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(536, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(537, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(538, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(539, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(540, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(541, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(542, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(543, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(544, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(546, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(547, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(548, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(550, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(551, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(552, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(553, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(554, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(555, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(556, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(557, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(558, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(559, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(560, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(561, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(562, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(563, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(564, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(565, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(566, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(567, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(568, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(569, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(570, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(571, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(572, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(574, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(575, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(576, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(578, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(579, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(580, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(581, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(582, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(583, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(584, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(585, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(586, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(587, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(588, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(589, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(590, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(591, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(592, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(593, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(594, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(595, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(596, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(597, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(598, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(599, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(600, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(602, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(603, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(604, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(606, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(607, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(608, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(609, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(610, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(611, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(612, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(613, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(614, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(615, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(616, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(617, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(618, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(619, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(620, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(621, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(622, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(623, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(624, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(625, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(626, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(627, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(628, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(630, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(631, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(632, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(634, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(635, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(636, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(637, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(638, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(639, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(640, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(641, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(642, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(643, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(644, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(645, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(646, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(647, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(648, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(649, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(650, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(651, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(652, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(653, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(654, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(655, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(656, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(658, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(659, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(660, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(662, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(663, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(664, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(665, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(666, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(667, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(668, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(669, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(670, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(671, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(672, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(673, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(674, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(675, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(676, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(677, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(678, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(679, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(680, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(681, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(682, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(683, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(684, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(686, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(687, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL);
INSERT INTO `masters_functional_areas` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(688, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(690, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(691, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(692, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(693, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(694, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(695, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(696, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(697, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(698, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(699, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(700, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(701, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(702, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(703, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(704, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(705, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(706, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(707, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(708, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(709, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(710, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(711, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(712, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(714, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(715, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(716, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(717, 'EDP Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(718, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(719, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(720, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(721, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(722, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(723, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(724, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(725, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(726, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(727, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(728, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(729, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(730, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(731, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(732, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(733, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(734, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(735, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(736, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(737, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(738, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(739, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(740, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(742, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(743, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(744, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(746, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(747, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(748, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(749, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(750, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(751, 'Software Development', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(752, 'System Analyst', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(753, 'Software Architecture', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(754, 'Database Architecture / Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(755, 'Testing', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(756, 'Graphic / Web Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(757, 'Product Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(758, 'Release Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(759, 'DBA', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(760, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(761, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(762, 'System Security', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(763, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(764, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(765, 'Webmaster', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(766, 'IT / Networking', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(767, 'Information Systems (MIS)', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(768, 'System Integration Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(770, 'Datawarehousing Technician', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(771, 'Outside Technical Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(772, 'Functional Outside Consultant', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(774, 'Technical Writer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(775, 'Instructional Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(776, 'Technical Documentor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(777, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(778, 'Project Manager IT / Software', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(779, 'Counsellor', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(780, 'Librarian', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(781, 'Teacher', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(782, 'Special Education Teacher', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(783, 'Translator', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(784, 'Transcriptionist', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(785, 'Junior / Primary / Assistant Teacher', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(786, 'Classroom Coordinator', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(787, 'Principal', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(788, 'Curriculum Designer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(789, 'Lab Management', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(790, 'Lecturer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(791, 'Tech Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(792, 'Customer Support', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(793, 'RF Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(794, 'RF Installation Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(795, 'RF System Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(796, 'GPRS Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(797, 'GSM Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(798, 'Embedded Technologies Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(799, 'Switching / Router Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(800, 'Mechanical Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(801, 'Civil Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(802, 'Electrical Engineer Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(803, 'Network Planning', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(804, 'Security Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(805, 'Maintenance Engineer', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(806, 'Hardware Design', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(807, 'Hardware Installation', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(808, 'QA / QC', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(809, 'Network Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(810, 'System Admin', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(811, 'Project Manager Telecom', 'active', '2018-01-31 11:56:05', 1, NULL, NULL),
(812, 'Others', 'active', '2018-01-31 11:56:05', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_industries`
--

CREATE TABLE `masters_industries` (
  `id` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Dumping data for table `masters_industries`
--

INSERT INTO `masters_industries` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Accounting / Finance', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(2, 'Advertising / PR / MR / Events', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(3, 'Agriculture / Dairy', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(4, 'Animation ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(5, 'Architecture / Interior Design ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(6, 'Auto / Auto Ancillary ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(7, 'Aviation / Aerospace', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(8, 'Banking / Financial Services / Broking', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(9, 'BPO / ITES', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(10, 'Brewery / Distillery', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(11, 'Chemicals / Petrochemical / Plastic / Rubber', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(12, 'Construction / Engineering / Cement / Metals ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(13, 'Consumer Durables', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(14, 'Courier / Transport / Freight ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(15, 'Ceramics / Sanitary Ware', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(16, 'Defence / Government ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(17, 'Education / Teaching / Training ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(18, 'Electrical / Switchgears', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(19, 'Export / Import ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(20, 'Facility Management ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(21, 'Fertilizers / Pesticides ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(22, 'FMCG / Foods / Beverage ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(23, 'Food Processing', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(24, 'Fresher / Trainee', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(25, 'Gems / Jewellery ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(26, 'Glass', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(27, 'Heat Ventilation Air Conditioning ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(28, 'Industrial Products / Heavy Machinery ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(29, 'Insurance', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(30, 'IT - Software / Software Services', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(31, 'IT - Hardware / Networking ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(32, 'Telecom / ISP ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(33, 'KPO / Research / Analytics ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(34, 'Legal ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(35, 'Media / Dotcom / Entertainment ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(36, 'Internet / Ecommerce', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(37, 'Medical / Healthcare / Hospital ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(38, 'Mining ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(39, 'NGO / Social Services', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(40, 'Paper', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(41, 'Pharma / Biotech / Clinical Research', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(42, 'Printing / Packaging ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(43, 'Publishing ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(44, 'REAL Estate ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(45, 'Recruitment ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(46, 'Retail ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(47, 'Security / Law Enforcement ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(48, 'Semiconductors / Electronics', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(49, 'Shipping / Marine ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(50, 'Steel ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(51, 'Strategy / Management Consulting Firms', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(52, 'Textiles / Garments / Accessories', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(53, 'Tyres ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(54, 'Water Treatment / Waste Management ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(55, 'Wellness / Fitness / Sports ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL),
(56, 'Others ', 'active', '2018-01-30 15:54:02', 1, '2018-01-30 10:24:02', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_institutes`
--

CREATE TABLE `masters_institutes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) CHARACTER SET latin1 NOT NULL,
  `status` enum('active','inactive') COLLATE utf8_unicode_ci NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `masters_job_roles`
--

CREATE TABLE `masters_job_roles` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `masters_keywords`
--

CREATE TABLE `masters_keywords` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_keywords`
--

INSERT INTO `masters_keywords` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(12, 'First job', 'active', '2018-04-02 06:57:37', 20, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_specializations`
--

CREATE TABLE `masters_specializations` (
  `id` int(11) NOT NULL,
  `degree_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_specializations`
--

INSERT INTO `masters_specializations` (`id`, `degree_id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 1, 'Arts', 'active', NULL, 1, NULL, NULL),
(2, 1, 'Communication ', 'active', NULL, 1, NULL, NULL),
(3, 1, 'Economics', 'active', NULL, 1, NULL, NULL),
(4, 1, 'English', 'active', NULL, 1, NULL, NULL),
(5, 1, 'Film', 'active', NULL, 1, NULL, NULL),
(6, 1, 'Fine Arts ', 'active', NULL, 1, NULL, NULL),
(7, 1, 'Hindia', 'active', NULL, 1, NULL, NULL),
(8, 1, 'History ', 'active', NULL, 1, NULL, NULL),
(9, 1, 'Journalism ', 'active', NULL, 1, NULL, NULL),
(10, 1, 'Maths', 'active', NULL, 1, NULL, NULL),
(11, 1, 'Pass Course', 'active', NULL, 1, NULL, NULL),
(12, 1, 'Political Science', 'active', NULL, 1, NULL, NULL),
(13, 1, 'PR / Advertising ', 'active', NULL, 1, NULL, NULL),
(14, 1, 'Psychology ', 'active', NULL, 1, NULL, NULL),
(15, 1, 'Sanskrit', 'active', NULL, 1, NULL, NULL),
(16, 1, 'Sociology ', 'active', NULL, 1, NULL, NULL),
(17, 1, 'Statistics', 'active', NULL, 1, NULL, NULL),
(18, 1, 'Vocational Course', 'active', NULL, 1, NULL, NULL),
(19, 1, 'Others', 'active', NULL, 1, NULL, NULL),
(20, 10, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(21, 10, 'Anthropology', 'active', NULL, 1, NULL, NULL),
(22, 10, 'Biochemistry', 'active', NULL, 1, NULL, NULL),
(23, 10, 'Biology', 'active', NULL, 1, NULL, NULL),
(24, 10, 'Botany', 'active', NULL, 1, NULL, NULL),
(25, 10, 'Chemistry', 'active', NULL, 1, NULL, NULL),
(26, 10, 'Computers', 'active', NULL, 1, NULL, NULL),
(27, 10, 'Dairy Technology', 'active', NULL, 1, NULL, NULL),
(28, 10, 'Electronics', 'active', NULL, 1, NULL, NULL),
(29, 10, 'Environmental Science', 'active', NULL, 1, NULL, NULL),
(30, 10, 'Food Technology', 'active', NULL, 1, NULL, NULL),
(31, 10, 'Geology', 'active', NULL, 1, NULL, NULL),
(32, 10, 'Home Science', 'active', NULL, 1, NULL, NULL),
(33, 10, 'Maths', 'active', NULL, 1, NULL, NULL),
(34, 10, 'Microbiology', 'active', NULL, 1, NULL, NULL),
(35, 10, 'Nursing', 'active', NULL, 1, NULL, NULL),
(36, 10, 'Physics', 'active', NULL, 1, NULL, NULL),
(37, 10, 'Statistics', 'active', NULL, 1, NULL, NULL),
(38, 10, 'Zoology', 'active', NULL, 1, NULL, NULL),
(39, 10, 'General ', 'active', NULL, 1, NULL, NULL),
(40, 10, 'Others', 'active', NULL, 1, NULL, NULL),
(41, 12, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(42, 12, 'Automobile', 'active', NULL, 1, NULL, NULL),
(43, 12, 'Aviation ', 'active', NULL, 1, NULL, NULL),
(44, 12, 'Biochemistry / BioTechnology', 'active', NULL, 1, NULL, NULL),
(45, 12, 'Biomedical', 'active', NULL, 1, NULL, NULL),
(46, 12, 'Ceramics', 'active', NULL, 1, NULL, NULL),
(47, 12, 'Chemical', 'active', NULL, 1, NULL, NULL),
(48, 12, 'Civic', 'active', NULL, 1, NULL, NULL),
(49, 12, 'Computers', 'active', NULL, 1, NULL, NULL),
(50, 12, 'Electrical', 'active', NULL, 1, NULL, NULL),
(51, 12, 'Electronics / Telecommunication', 'active', NULL, 1, NULL, NULL),
(52, 12, 'Energy', 'active', NULL, 1, NULL, NULL),
(53, 12, 'Environmental ', 'active', NULL, 1, NULL, NULL),
(54, 12, 'Instrumentation', 'active', NULL, 1, NULL, NULL),
(55, 12, 'Marine', 'active', NULL, 1, NULL, NULL),
(56, 12, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(57, 12, 'Metallurgy', 'active', NULL, 1, NULL, NULL),
(58, 12, 'Mineral', 'active', NULL, 1, NULL, NULL),
(59, 12, 'Mining', 'active', NULL, 1, NULL, NULL),
(60, 12, 'Nuclear', 'active', NULL, 1, NULL, NULL),
(61, 12, 'Paint / Oil ', 'active', NULL, 1, NULL, NULL),
(62, 12, 'Petroleum', 'active', NULL, 1, NULL, NULL),
(63, 12, 'Plastics ', 'active', NULL, 1, NULL, NULL),
(64, 12, 'Production / Industrial ', 'active', NULL, 1, NULL, NULL),
(65, 13, 'Human Resource', 'active', NULL, 1, NULL, NULL),
(66, 13, 'Finance', 'active', NULL, 1, NULL, NULL),
(67, 13, 'Marketing ', 'active', NULL, 1, NULL, NULL),
(68, 17, 'Architecture', 'active', NULL, 1, NULL, NULL),
(69, 17, 'Chemical', 'active', NULL, 1, NULL, NULL),
(70, 17, 'Civil', 'active', NULL, 1, NULL, NULL),
(71, 17, 'Computers', 'active', NULL, 1, NULL, NULL),
(72, 17, 'Electrical', 'active', NULL, 1, NULL, NULL),
(73, 17, 'Electronics / Telecommunication', 'active', NULL, 1, NULL, NULL),
(74, 17, 'Engineering ', 'active', NULL, 1, NULL, NULL),
(75, 17, 'Export / Import ', 'active', NULL, 1, NULL, NULL),
(76, 17, 'Fashion Designing / Other Designing ', 'active', NULL, 1, NULL, NULL),
(77, 17, 'Graphic / Web Designing', 'active', NULL, 1, NULL, NULL),
(78, 17, 'Hotel Management ', 'active', NULL, 1, NULL, NULL),
(79, 17, 'Insurance ', 'active', NULL, 1, NULL, NULL),
(80, 17, 'Management ', 'active', NULL, 1, NULL, NULL),
(81, 17, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(82, 17, 'Tourism', 'active', NULL, 1, NULL, NULL),
(83, 17, 'Visual Arts', 'active', NULL, 1, NULL, NULL),
(84, 17, 'Vocational Course', 'active', NULL, 1, NULL, NULL),
(85, 17, 'Others', 'active', NULL, 1, NULL, NULL),
(86, 20, 'C. A. Inter', 'active', NULL, 1, NULL, NULL),
(87, 20, 'C. A. ', 'active', NULL, 1, NULL, NULL),
(88, 22, 'C. S. Inter', 'active', NULL, 1, NULL, NULL),
(89, 22, 'C. S. ', 'active', NULL, 1, NULL, NULL),
(90, 23, 'I. C. W. A. Inter ', 'active', NULL, 1, NULL, NULL),
(91, 23, 'I. C. W. A. ', 'active', NULL, 1, NULL, NULL),
(92, 25, 'Anthropology', 'active', NULL, 1, NULL, NULL),
(93, 25, 'Arts ', 'active', NULL, 1, NULL, NULL),
(94, 25, 'Communication ', 'active', NULL, 1, NULL, NULL),
(95, 25, 'Economics', 'active', NULL, 1, NULL, NULL),
(96, 25, 'English', 'active', NULL, 1, NULL, NULL),
(97, 25, 'Film', 'active', NULL, 1, NULL, NULL),
(98, 25, 'Fine Arts ', 'active', NULL, 1, NULL, NULL),
(99, 25, 'Hindi', 'active', NULL, 1, NULL, NULL),
(100, 25, 'History ', 'active', NULL, 1, NULL, NULL),
(101, 25, 'Journalism ', 'active', NULL, 1, NULL, NULL),
(102, 25, 'Maths', 'active', NULL, 1, NULL, NULL),
(103, 25, 'Political Science', 'active', NULL, 1, NULL, NULL),
(104, 25, 'PR / Advertising ', 'active', NULL, 1, NULL, NULL),
(105, 25, 'Psychology ', 'active', NULL, 1, NULL, NULL),
(106, 25, 'Sanskrit', 'active', NULL, 1, NULL, NULL),
(107, 25, 'Sociology ', 'active', NULL, 1, NULL, NULL),
(108, 25, 'Statistics', 'active', NULL, 1, NULL, NULL),
(109, 25, 'Others', 'active', NULL, 1, NULL, NULL),
(110, 30, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(111, 30, 'Anthropology', 'active', NULL, 1, NULL, NULL),
(112, 30, 'Bio-chemistry', 'active', NULL, 1, NULL, NULL),
(113, 30, 'Biology', 'active', NULL, 1, NULL, NULL),
(114, 30, 'Botany', 'active', NULL, 1, NULL, NULL),
(115, 30, 'Chemistry', 'active', NULL, 1, NULL, NULL),
(116, 30, 'Computers', 'active', NULL, 1, NULL, NULL),
(117, 30, 'Dairy Technology', 'active', NULL, 1, NULL, NULL),
(118, 30, 'Electronics', 'active', NULL, 1, NULL, NULL),
(119, 30, 'Environmental Science', 'active', NULL, 1, NULL, NULL),
(120, 30, 'Food Technology', 'active', NULL, 1, NULL, NULL),
(121, 30, 'Geology', 'active', NULL, 1, NULL, NULL),
(122, 30, 'Home Science', 'active', NULL, 1, NULL, NULL),
(123, 30, 'Maths', 'active', NULL, 1, NULL, NULL),
(124, 30, 'Microbiology', 'active', NULL, 1, NULL, NULL),
(125, 30, 'Nursing', 'active', NULL, 1, NULL, NULL),
(126, 30, 'Physics', 'active', NULL, 1, NULL, NULL),
(127, 30, 'Statistics', 'active', NULL, 1, NULL, NULL),
(128, 30, 'Zoology', 'active', NULL, 1, NULL, NULL),
(129, 30, 'Others', 'active', NULL, 1, NULL, NULL),
(130, 33, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(131, 33, 'Automobile', 'active', NULL, 1, NULL, NULL),
(132, 33, 'Aviation ', 'active', NULL, 1, NULL, NULL),
(133, 33, 'Biochemistry / BioTechnology', 'active', NULL, 1, NULL, NULL),
(134, 33, 'Biomedical', 'active', NULL, 1, NULL, NULL),
(135, 33, 'Ceramics', 'active', NULL, 1, NULL, NULL),
(136, 33, 'Chemical', 'active', NULL, 1, NULL, NULL),
(137, 33, 'Civic', 'active', NULL, 1, NULL, NULL),
(138, 33, 'Computers', 'active', NULL, 1, NULL, NULL),
(139, 33, 'Electrical', 'active', NULL, 1, NULL, NULL),
(140, 33, 'Electronics / Telecommunication', 'active', NULL, 1, NULL, NULL),
(141, 33, 'Energy', 'active', NULL, 1, NULL, NULL),
(142, 33, 'Environmental ', 'active', NULL, 1, NULL, NULL),
(143, 33, 'Instrumentation', 'active', NULL, 1, NULL, NULL),
(144, 33, 'Marine', 'active', NULL, 1, NULL, NULL),
(145, 33, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(146, 33, 'Metallurgy', 'active', NULL, 1, NULL, NULL),
(147, 33, 'Mineral', 'active', NULL, 1, NULL, NULL),
(148, 33, 'Mining', 'active', NULL, 1, NULL, NULL),
(149, 33, 'Nuclear', 'active', NULL, 1, NULL, NULL),
(150, 33, 'Paint / Oil ', 'active', NULL, 1, NULL, NULL),
(151, 33, 'Petroleum', 'active', NULL, 1, NULL, NULL),
(152, 33, 'Plastics ', 'active', NULL, 1, NULL, NULL),
(153, 33, 'Production / Industrial ', 'active', NULL, 1, NULL, NULL),
(154, 34, 'Advertising / Mass Communication', 'active', NULL, 1, NULL, NULL),
(155, 34, 'Finance', 'active', NULL, 1, NULL, NULL),
(156, 34, 'HR / Industrial Relations', 'active', NULL, 1, NULL, NULL),
(157, 34, 'Information Technology', 'active', NULL, 1, NULL, NULL),
(158, 34, 'International Business ', 'active', NULL, 1, NULL, NULL),
(159, 34, 'Marketing ', 'active', NULL, 1, NULL, NULL),
(160, 34, 'Systems', 'active', NULL, 1, NULL, NULL),
(161, 34, 'Other Management ', 'active', NULL, 1, NULL, NULL),
(162, 34, 'Others ', 'active', NULL, 1, NULL, NULL),
(163, 35, 'Cardiology', 'active', NULL, 1, NULL, NULL),
(164, 35, 'Dermatology', 'active', NULL, 1, NULL, NULL),
(165, 35, 'ENT', 'active', NULL, 1, NULL, NULL),
(166, 35, 'General Practitioner', 'active', NULL, 1, NULL, NULL),
(167, 35, 'Gynecology', 'active', NULL, 1, NULL, NULL),
(168, 35, 'Hepatology', 'active', NULL, 1, NULL, NULL),
(169, 35, 'Immunology', 'active', NULL, 1, NULL, NULL),
(170, 35, 'Microbiology', 'active', NULL, 1, NULL, NULL),
(171, 35, 'Neonatal', 'active', NULL, 1, NULL, NULL),
(172, 35, 'Nephrology', 'active', NULL, 1, NULL, NULL),
(173, 35, 'Urology', 'active', NULL, 1, NULL, NULL),
(174, 35, 'Obstetrics', 'active', NULL, 1, NULL, NULL),
(175, 35, 'Oncology', 'active', NULL, 1, NULL, NULL),
(176, 35, 'Ophthalmology', 'active', NULL, 1, NULL, NULL),
(177, 35, 'Orthopedic', 'active', NULL, 1, NULL, NULL),
(178, 35, 'Pathology', 'active', NULL, 1, NULL, NULL),
(179, 35, 'Pediatrics', 'active', NULL, 1, NULL, NULL),
(180, 35, 'Psychiatry', 'active', NULL, 1, NULL, NULL),
(181, 35, 'Psychology', 'active', NULL, 1, NULL, NULL),
(182, 35, 'Radiology', 'active', NULL, 1, NULL, NULL),
(183, 35, 'Rheumatology', 'active', NULL, 1, NULL, NULL),
(184, 35, 'Others', 'active', NULL, 1, NULL, NULL),
(185, 36, 'Chemical', 'active', NULL, 1, NULL, NULL),
(186, 36, 'Civil ', 'active', NULL, 1, NULL, NULL),
(187, 36, 'Computers', 'active', NULL, 1, NULL, NULL),
(188, 36, 'Electrical', 'active', NULL, 1, NULL, NULL),
(189, 36, 'Electronics', 'active', NULL, 1, NULL, NULL),
(190, 36, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(191, 36, 'Others', 'active', NULL, 1, NULL, NULL),
(192, 37, 'Advertising / Mass Communication', 'active', NULL, 1, NULL, NULL),
(193, 37, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(194, 37, 'Anthropology', 'active', NULL, 1, NULL, NULL),
(195, 37, 'Architecture', 'active', NULL, 1, NULL, NULL),
(196, 37, 'Arts', 'active', NULL, 1, NULL, NULL),
(197, 37, 'Automobile', 'active', NULL, 1, NULL, NULL),
(198, 37, 'Aviation ', 'active', NULL, 1, NULL, NULL),
(199, 37, 'Biochemistry / BioTechnology', 'active', NULL, 1, NULL, NULL),
(200, 37, 'Biomedical', 'active', NULL, 1, NULL, NULL),
(201, 37, 'Biotechnology', 'active', NULL, 1, NULL, NULL),
(202, 37, 'Ceramics', 'active', NULL, 1, NULL, NULL),
(203, 37, 'Chemical', 'active', NULL, 1, NULL, NULL),
(204, 37, 'Chemistry', 'active', NULL, 1, NULL, NULL),
(205, 37, 'Civil', 'active', NULL, 1, NULL, NULL),
(206, 37, 'Commerce', 'active', NULL, 1, NULL, NULL),
(207, 37, 'Communication ', 'active', NULL, 1, NULL, NULL),
(208, 37, 'Computers', 'active', NULL, 1, NULL, NULL),
(209, 37, 'Dairy Technology', 'active', NULL, 1, NULL, NULL),
(210, 37, 'Dermatology', 'active', NULL, 1, NULL, NULL),
(211, 37, 'Economics', 'active', NULL, 1, NULL, NULL),
(212, 37, 'Electrical', 'active', NULL, 1, NULL, NULL),
(213, 37, 'Electronics / Telecommunication', 'active', NULL, 1, NULL, NULL),
(214, 37, 'Energy', 'active', NULL, 1, NULL, NULL),
(215, 37, 'ENT', 'active', NULL, 1, NULL, NULL),
(216, 37, 'Environmental ', 'active', NULL, 1, NULL, NULL),
(217, 37, 'Fashion Designing / Other Designing ', 'active', NULL, 1, NULL, NULL),
(218, 37, 'Film', 'active', NULL, 1, NULL, NULL),
(219, 37, 'Finance', 'active', NULL, 1, NULL, NULL),
(220, 37, 'Fine Arts ', 'active', NULL, 1, NULL, NULL),
(221, 37, 'Food Technology', 'active', NULL, 1, NULL, NULL),
(222, 37, 'Hotel Management ', 'active', NULL, 1, NULL, NULL),
(223, 37, 'History ', 'active', NULL, 1, NULL, NULL),
(224, 37, 'HR / Industrial Relations', 'active', NULL, 1, NULL, NULL),
(225, 37, 'Immunology', 'active', NULL, 1, NULL, NULL),
(226, 37, 'International Business', 'active', NULL, 1, NULL, NULL),
(227, 37, 'Instrumentation', 'active', NULL, 1, NULL, NULL),
(228, 37, 'Journalism ', 'active', NULL, 1, NULL, NULL),
(229, 37, 'Law', 'active', NULL, 1, NULL, NULL),
(230, 37, 'Literature', 'active', NULL, 1, NULL, NULL),
(231, 37, 'Marine', 'active', NULL, 1, NULL, NULL),
(232, 37, 'Marketing ', 'active', NULL, 1, NULL, NULL),
(233, 37, 'Maths', 'active', NULL, 1, NULL, NULL),
(234, 37, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(235, 37, 'Medicine', 'active', NULL, 1, NULL, NULL),
(236, 37, 'Metallurgy', 'active', NULL, 1, NULL, NULL),
(237, 37, 'Microbiology', 'active', NULL, 1, NULL, NULL),
(238, 37, 'Mineral', 'active', NULL, 1, NULL, NULL),
(239, 37, 'Mining', 'active', NULL, 1, NULL, NULL),
(240, 37, 'Neonatal', 'active', NULL, 1, NULL, NULL),
(241, 37, 'Nuclear', 'active', NULL, 1, NULL, NULL),
(242, 37, 'Obstetrics', 'active', NULL, 1, NULL, NULL),
(243, 37, 'Paint / Oil ', 'active', NULL, 1, NULL, NULL),
(244, 37, 'Pathology', 'active', NULL, 1, NULL, NULL),
(245, 37, 'Pediatrics', 'active', NULL, 1, NULL, NULL),
(246, 37, 'Pharmacy', 'active', NULL, 1, NULL, NULL),
(247, 37, 'Physics', 'active', NULL, 1, NULL, NULL),
(248, 37, 'Plastics ', 'active', NULL, 1, NULL, NULL),
(249, 37, 'Production / Industrial ', 'active', NULL, 1, NULL, NULL),
(250, 37, 'Psychiatry', 'active', NULL, 1, NULL, NULL),
(251, 37, 'Psychology', 'active', NULL, 1, NULL, NULL),
(252, 37, 'Radiology', 'active', NULL, 1, NULL, NULL),
(253, 37, 'Rheumatology', 'active', NULL, 1, NULL, NULL),
(254, 37, 'Sanskrit', 'active', NULL, 1, NULL, NULL),
(255, 37, 'Sociology ', 'active', NULL, 1, NULL, NULL),
(256, 37, 'Statistics', 'active', NULL, 1, NULL, NULL),
(257, 37, 'Systems', 'active', NULL, 1, NULL, NULL),
(258, 37, 'Textile', 'active', NULL, 1, NULL, NULL),
(259, 37, 'Vocational Course', 'active', NULL, 1, NULL, NULL),
(260, 37, 'Other Arts ', 'active', NULL, 1, NULL, NULL),
(261, 37, 'Others', 'active', NULL, 1, NULL, NULL),
(262, 37, 'Other Engineering ', 'active', NULL, 1, NULL, NULL),
(263, 37, 'Other Management ', 'active', NULL, 1, NULL, NULL),
(264, 38, 'Advertising / Mass Communication', 'active', NULL, 1, NULL, NULL),
(265, 38, 'Agriculture', 'active', NULL, 1, NULL, NULL),
(266, 38, 'Anthropology', 'active', NULL, 1, NULL, NULL),
(267, 38, 'Architecture', 'active', NULL, 1, NULL, NULL),
(268, 38, 'Arts', 'active', NULL, 1, NULL, NULL),
(269, 38, 'Automobile', 'active', NULL, 1, NULL, NULL),
(270, 38, 'Aviation ', 'active', NULL, 1, NULL, NULL),
(271, 38, 'Biochemistry / BioTechnology', 'active', NULL, 1, NULL, NULL),
(272, 38, 'Biomedical', 'active', NULL, 1, NULL, NULL),
(273, 38, 'Biotechnology', 'active', NULL, 1, NULL, NULL),
(274, 38, 'Ceramics', 'active', NULL, 1, NULL, NULL),
(275, 38, 'Chemical', 'active', NULL, 1, NULL, NULL),
(276, 38, 'Chemistry', 'active', NULL, 1, NULL, NULL),
(277, 38, 'Civil', 'active', NULL, 1, NULL, NULL),
(278, 38, 'Commerce', 'active', NULL, 1, NULL, NULL),
(279, 38, 'Communication ', 'active', NULL, 1, NULL, NULL),
(280, 38, 'Computers', 'active', NULL, 1, NULL, NULL),
(281, 38, 'Dairy Technology', 'active', NULL, 1, NULL, NULL),
(282, 38, 'Economics', 'active', NULL, 1, NULL, NULL),
(283, 38, 'Electrical', 'active', NULL, 1, NULL, NULL),
(284, 38, 'Electronics / Telecommunication', 'active', NULL, 1, NULL, NULL),
(285, 38, 'Energy', 'active', NULL, 1, NULL, NULL),
(286, 38, 'ENT', 'active', NULL, 1, NULL, NULL),
(287, 38, 'Environmental ', 'active', NULL, 1, NULL, NULL),
(288, 38, 'Fashion Designing / Other Designing ', 'active', NULL, 1, NULL, NULL),
(289, 38, 'Film', 'active', NULL, 1, NULL, NULL),
(290, 38, 'Finance', 'active', NULL, 1, NULL, NULL),
(291, 38, 'Fine Arts ', 'active', NULL, 1, NULL, NULL),
(292, 38, 'Food Technology', 'active', NULL, 1, NULL, NULL),
(293, 38, 'Hotel Management ', 'active', NULL, 1, NULL, NULL),
(294, 38, 'History ', 'active', NULL, 1, NULL, NULL),
(295, 38, 'HR / Industrial Relations', 'active', NULL, 1, NULL, NULL),
(296, 38, 'Immunology', 'active', NULL, 1, NULL, NULL),
(297, 38, 'International Business', 'active', NULL, 1, NULL, NULL),
(298, 38, 'Instrumentation', 'active', NULL, 1, NULL, NULL),
(299, 38, 'Journalism ', 'active', NULL, 1, NULL, NULL),
(300, 38, 'Law', 'active', NULL, 1, NULL, NULL),
(301, 38, 'Literature', 'active', NULL, 1, NULL, NULL),
(302, 38, 'Marine', 'active', NULL, 1, NULL, NULL),
(303, 38, 'Marketing ', 'active', NULL, 1, NULL, NULL),
(304, 38, 'Maths', 'active', NULL, 1, NULL, NULL),
(305, 38, 'Mechanical', 'active', NULL, 1, NULL, NULL),
(306, 38, 'Medicine', 'active', NULL, 1, NULL, NULL),
(307, 38, 'Metallurgy', 'active', NULL, 1, NULL, NULL),
(308, 38, 'Microbiology', 'active', NULL, 1, NULL, NULL),
(309, 38, 'Mineral', 'active', NULL, 1, NULL, NULL),
(310, 38, 'Mining', 'active', NULL, 1, NULL, NULL),
(311, 38, 'Neonatal', 'active', NULL, 1, NULL, NULL),
(312, 38, 'Nuclear', 'active', NULL, 1, NULL, NULL),
(313, 38, 'Obstetrics', 'active', NULL, 1, NULL, NULL),
(314, 38, 'Paint / Oil ', 'active', NULL, 1, NULL, NULL),
(315, 38, 'Petroleum', 'active', NULL, 1, NULL, NULL),
(316, 38, 'Pediatrics', 'active', NULL, 1, NULL, NULL),
(317, 38, 'Pharmacy', 'active', NULL, 1, NULL, NULL),
(318, 38, 'Physics', 'active', NULL, 1, NULL, NULL),
(319, 38, 'Plastics ', 'active', NULL, 1, NULL, NULL),
(320, 38, 'Production / Industrial ', 'active', NULL, 1, NULL, NULL),
(321, 38, 'Psychiatry', 'active', NULL, 1, NULL, NULL),
(322, 38, 'Psychology ', 'active', NULL, 1, NULL, NULL),
(323, 38, 'Radiology', 'active', NULL, 1, NULL, NULL),
(324, 38, 'Rheumatology', 'active', NULL, 1, NULL, NULL),
(325, 38, 'Sanskrit', 'active', NULL, 1, NULL, NULL),
(326, 38, 'Sociology ', 'active', NULL, 1, NULL, NULL),
(327, 38, 'Statistics', 'active', NULL, 1, NULL, NULL),
(328, 38, 'Systems', 'active', NULL, 1, NULL, NULL),
(329, 38, 'Textile', 'active', NULL, 1, NULL, NULL),
(330, 38, 'Vocational Course', 'active', NULL, 1, NULL, NULL),
(331, 38, 'Other Arts ', 'active', NULL, 1, NULL, NULL),
(332, 38, 'Other Engineering ', 'active', NULL, 1, NULL, NULL),
(333, 38, 'Other Management ', 'active', NULL, 1, NULL, NULL),
(334, 38, 'Other Science', 'active', NULL, 1, NULL, NULL),
(335, 38, 'Others', 'active', NULL, 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `masters_trainings`
--

CREATE TABLE `masters_trainings` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` varchar(10) NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `masters_trainings`
--

INSERT INTO `masters_trainings` (`id`, `name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 'Virtual Training', 'active', '2018-03-28 11:38:50', 1, NULL, NULL),
(2, 'Online Training', 'active', '2018-03-28 11:38:58', 1, NULL, NULL),
(3, 'Classroom Training', 'active', '2018-03-28 11:39:06', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `run_on` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `name`, `run_on`) VALUES
(1, '/20180105124718-initial-db', '2018-02-06 11:00:29'),
(2, '/20180108115300-job-shortlisted-table-rename', '2018-02-06 11:00:43'),
(3, '/20180109111430-masters-employers-table-delete', '2018-02-06 11:00:52'),
(4, '/20180109115924-foreign-key-constraint-update', '2018-02-06 11:01:13'),
(5, '/20180109135442-users-organizations-table', '2018-02-06 11:01:17'),
(6, '/20180109184549-users-organizations-foreign-key-update', '2018-02-06 11:01:18'),
(7, '/20180110063313-add-user-id-organization-tbl', '2018-02-06 11:01:19'),
(8, '/20180110113824-countries-table-data', '2018-02-06 11:01:20'),
(9, '/20180112145612-institute-names-table', '2018-02-06 11:01:20'),
(10, '/20180112151447-institute-name-table-rename', '2018-02-06 11:01:24'),
(11, '/20180115074553-email-template-data', '2018-02-06 11:01:24'),
(12, '/20180115075834-organization-user-constraint-update', '2018-02-06 11:01:27'),
(13, '/20180117050350-master-cities-added-insted-client-locations', '2018-02-06 11:01:28'),
(14, '/20180117073106-update-master-country', '2018-02-06 11:01:29'),
(15, '/20180117100554-users-table-password-token-column-update', '2018-02-06 11:01:30'),
(16, '/20180117110237-client-locaiton-id-constraint-update', '2018-02-06 11:01:34'),
(17, '/20180117153414-organizations-status-column-update', '2018-02-06 11:01:35'),
(18, '/20180118072239-jobs-table-client-id-column-added', '2018-02-06 11:01:36'),
(19, '/20180119143848-users-organizations-created-by-constraint-update', '2018-02-06 11:01:43'),
(20, '/20180122113829-user-candidate-update', '2018-02-06 11:01:44'),
(21, '/20180123070733-user-candidate-job-role-update-col', '2018-02-06 11:01:46'),
(22, '/20180123071339-users-locations-table-location-column-reference-update', '2018-02-06 11:01:47'),
(23, '/20180124145244-jobs-users-table-is-job-sent-column-added', '2018-02-06 11:01:48'),
(24, '/20180125091717-jobs-users-table-job-sent-audit-columns-added', '2018-02-06 11:01:52'),
(25, '/20180125112207-update-other-country-id-with-varchar', '2018-02-06 11:01:55'),
(26, '/20180129081233-user-resume-update', '2018-02-06 11:01:56'),
(27, '/20180130115700-masters-cities-table-state-column-added', '2018-02-06 11:01:58'),
(28, '/20180131101656-interview-feedback-update', '2018-02-06 11:02:00'),
(29, '/20180131144608-jobs-table-job-type-and-employment-type-columns-added', '2018-02-06 11:02:05'),
(30, '/20180202120249-interview-job-application-update', '2018-02-06 11:02:06'),
(31, '/20180202123244-interview-update', '2018-02-06 11:02:07'),
(32, '/20180205085619-add-comment-job-application-table', '2018-02-06 11:02:09'),
(33, '/20180205102033-countries-table-name-columns-update', '2018-02-06 11:02:12'),
(34, '/20180205111138-countries-table-not-null-columns-update', '2018-02-06 11:02:13'),
(35, '/20180205140256-jobs-table-job-role-id-rename-update', '2018-02-06 11:02:15'),
(36, '/20180206061206-create-master-template', '2018-02-06 11:52:28'),
(37, '/20180206132208-master-specialization-update', '0000-00-00 00:00:00'),
(38, '/20180206132344-master-template', '0000-00-00 00:00:00'),
(40, '/20180208062059-master-template-insert-account-creation', '2018-02-08 11:56:00'),
(41, '/20180209074757-masters-email-templates-update', '2018-02-09 18:06:02'),
(42, '/20180209075316-default-user-organization-and-client-details-update', '2018-02-09 18:06:02'),
(43, '/20180209123820-email-template-add-set-password', '0000-00-00 00:00:00'),
(44, '/20180213125706-update-interview', '0000-00-00 00:00:00'),
(45, '/20180215045442-update-interview-feedback', '0000-00-00 00:00:00'),
(46, '/20180216060002-update-job-applications', '0000-00-00 00:00:00'),
(47, '/20180214135919-users-reporting-table-create', '2018-02-16 17:12:38'),
(48, '/20180215081636-users-reporting-table-parent-user-id-column-update', '2018-02-16 17:12:39'),
(49, '/20180216112705-user-candidate-update', '2018-02-16 17:12:39'),
(50, '/20180221085112-update-users-skills', '0000-00-00 00:00:00'),
(51, '/20180222082054-update-users', '0000-00-00 00:00:00'),
(52, '/20180222114433-users-organizations-table-job-id-column-added', '2018-02-27 19:17:39'),
(53, '/20180226115649-hr-user-classification-default-value', '2018-02-27 19:17:39'),
(54, '/20180301082240-add-interview-end-time', '0000-00-00 00:00:00'),
(55, '/20180301100644-inscrese-mobile-size', '0000-00-00 00:00:00'),
(56, '/20180301123131-create-fields-users', '0000-00-00 00:00:00'),
(57, '/20180301125447-update-fields-users', '0000-00-00 00:00:00'),
(58, '/20180305090738-add-round-name', '0000-00-00 00:00:00'),
(59, '/20180305135939-add-attachment', '0000-00-00 00:00:00'),
(60, '/20180305143317-jobs-table-job-owner-id-column-added', '2018-03-06 17:54:20'),
(61, '/20180216071328-organizations-settings', '2018-03-12 17:05:16'),
(62, '/20180307124343-users-update-themefont', '2018-03-12 17:05:17'),
(63, '/20180308130514-add-emailtemplate', '0000-00-00 00:00:00'),
(64, '/20180309122228-add-status-jobs-users', '0000-00-00 00:00:00'),
(65, '/20180312112853-add-default-hr', '0000-00-00 00:00:00'),
(66, '/20180314101842-add-jobs-shortlisting', '0000-00-00 00:00:00'),
(67, '/20180315065507-rename-jobs-hr-with-jobs-interviewers', '0000-00-00 00:00:00'),
(68, '/20180315123221-create-jobs-hr', '0000-00-00 00:00:00'),
(69, '/20180326113051-organizations-update', '2018-03-26 18:16:28'),
(70, '/20180326125014-jobs-users-update', '0000-00-00 00:00:00'),
(71, '/20180327115526-email-template-update', '0000-00-00 00:00:00'),
(72, '/20180327130545-email-template-add-skip-update', '0000-00-00 00:00:00'),
(73, '/20180328081354-email-template-update-status', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `organizations`
--

CREATE TABLE `organizations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `domain_name` varchar(225) DEFAULT NULL,
  `status` enum('pending','active','inactive') NOT NULL DEFAULT 'pending',
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `organizations`
--

INSERT INTO `organizations` (`id`, `user_id`, `name`, `domain_name`, `status`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(1, 1, 'Acme', NULL, 'active', '2018-03-01 09:35:46', 1, NULL, NULL),
(2, 2, 'ACE', NULL, 'active', '2018-03-01 09:37:15', 1, NULL, NULL),
(3, 3, 'AFTEK', 'tech', 'active', '2018-03-01 09:40:00', 1, '2018-04-03 11:55:47', NULL),
(4, 33, '123', '123', 'active', '2018-03-29 11:41:47', 4, NULL, NULL),
(5, 45, 'New Org', 'new', 'active', '2018-04-02 06:54:58', 1, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `organizations_settings`
--

CREATE TABLE `organizations_settings` (
  `id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `value` text NOT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `modified_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `organizations_settings`
--

INSERT INTO `organizations_settings` (`id`, `organization_id`, `name`, `value`, `created`, `created_by`, `modified`, `modified_by`) VALUES
(781, 3, 'title', 'Recruitment', '2018-04-04 06:45:33', NULL, NULL, NULL),
(782, 3, 'logo', 'undefined', '2018-04-04 06:45:33', NULL, NULL, NULL),
(783, 3, 'favicon', 'undefined', '2018-04-04 06:45:33', NULL, NULL, NULL),
(784, 3, 'theme', 'default', '2018-04-04 06:45:33', NULL, NULL, NULL),
(785, 3, 'menu', 'left_menu', '2018-04-04 06:45:33', NULL, NULL, NULL),
(786, 3, 'candidate_registration', '1', '2018-04-04 06:45:33', NULL, NULL, NULL),
(787, 3, 'job_listing', '1', '2018-04-04 06:45:33', NULL, NULL, NULL),
(788, 3, 'from_email', 'recpro.agency@gmail.com', '2018-04-04 06:45:33', NULL, NULL, NULL),
(789, 3, 'cc_email', 'chandni.mathur@v2solutions.com', '2018-04-04 06:45:33', NULL, NULL, NULL),
(790, 3, 'port', '587', '2018-04-04 06:45:33', NULL, NULL, NULL),
(791, 3, 'ssl', '0', '2018-04-04 06:45:33', NULL, NULL, NULL),
(792, 3, 'server', 'smtp.gmail.com', '2018-04-04 06:45:33', NULL, NULL, NULL),
(793, 3, 'password', 'portal@123', '2018-04-04 06:45:33', NULL, NULL, NULL),
(794, 3, 'slogan', '', '2018-04-04 06:45:33', NULL, NULL, NULL),
(795, 3, 'description', '', '2018-04-04 06:45:33', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `registration_type` enum('admin','user','invite') NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(60) DEFAULT NULL,
  `password_token` varchar(1000) DEFAULT NULL,
  `firstname` varchar(50) NOT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `mobile_no` varchar(15) DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `profile_image` varchar(100) DEFAULT NULL,
  `role` varchar(20) NOT NULL,
  `user_classification` varchar(255) DEFAULT NULL,
  `theme_spacing` varchar(20) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `location_id` int(11) DEFAULT NULL,
  `status` enum('pending','active','inactive') NOT NULL DEFAULT 'pending',
  `created` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `registration_type`, `email`, `password`, `password_token`, `firstname`, `lastname`, `mobile_no`, `gender`, `dob`, `profile_image`, `role`, `user_classification`, `theme_spacing`, `department`, `designation`, `location_id`, `status`, `created`, `created_by`, `modified`) VALUES
(1, 'admin', 'demo@demo.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'Demo', 'Demo', '987654321', 'male', '2000-01-01', NULL, 'admin', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 09:35:46', NULL, NULL),
(2, 'admin', 'admin@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ace', 'admin', NULL, NULL, NULL, NULL, 'organization', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 09:37:15', 1, NULL),
(3, 'admin', 'admin@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'aftek', 'admin', NULL, NULL, NULL, '3.jpg', 'organization', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 09:40:00', 1, '2018-04-02 09:36:03'),
(4, 'admin', 'candidate1@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'one', '+91.6546544565', 'male', '1998-12-27', '4.jpg', 'candidate', NULL, 'compact', NULL, NULL, NULL, 'active', '2018-03-01 10:03:02', 3, '2018-04-02 14:47:10'),
(5, 'admin', 'candidate2@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'two', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:03:39', 3, '2018-03-01 15:36:35'),
(6, 'admin', 'candidate3@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'three', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:06:44', 3, NULL),
(7, 'admin', 'candidate4@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'four', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:06:52', 3, NULL),
(8, 'admin', 'candidate5@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'five', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:06:59', 3, NULL),
(9, 'admin', 'candidate6@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'six', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:07:54', 2, NULL),
(10, 'admin', 'candidate7@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'seven', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:08:03', 2, NULL),
(11, 'admin', 'candidate8@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'candidate', 'eight', '+91.3654656546', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:08:10', 2, NULL),
(12, 'admin', 'int1_infosys@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'infosys', 'interviewer1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:09:24', 2, NULL),
(13, 'admin', 'int2_infosys@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'infosys', 'interviewer2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:09:33', 2, NULL),
(14, 'admin', 'int1_symphony@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'symphony', 'interviewer1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:09:47', 2, NULL),
(15, 'admin', 'int2_symphony@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'symphony', 'interviewer2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:09:54', 2, NULL),
(16, 'admin', 'int1_google@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'google', 'interviewer1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:10:38', 3, NULL),
(17, 'admin', 'int2_google@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'google', 'interviewer2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:10:44', 3, NULL),
(18, 'admin', 'int1_ibm@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ibm', 'interviewer1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:10:58', 3, NULL),
(19, 'admin', 'int2_ibm@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ibm', 'interviewer2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:11:06', 3, NULL),
(20, 'admin', 'hr1@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'aftek', 'hr1', NULL, NULL, NULL, '20.jpg', 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:13:35', 3, '2018-04-02 09:35:25'),
(21, 'admin', 'hr2@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'aftek', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:14:23', 3, NULL),
(22, 'admin', 'hr1_google@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'google', 'hr1', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:15:15', 3, NULL),
(23, 'admin', 'hr2_google@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'google', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'external', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:17:09', 3, NULL),
(24, 'admin', 'hr1_ibm@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ibm', 'hr1', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:17:49', 3, NULL),
(25, 'admin', 'hr2_ibm@aftek.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ibm', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'external', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:18:46', 3, NULL),
(26, 'admin', 'hr1@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ace', 'hr1', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:26:03', 2, NULL),
(27, 'admin', 'hr2@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ace', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:27:28', 2, NULL),
(28, 'admin', 'hr1_infosys@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'infosys', 'hr1', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:29:21', 2, NULL),
(29, 'admin', 'hr2_infosys@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'infosys', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'external', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:30:06', 2, NULL),
(30, 'admin', 'hr1_symphony@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'symphony', 'hr1', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:30:51', 2, NULL),
(31, 'admin', 'hr2_symphony@ace.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'symphony', 'hr2', NULL, NULL, NULL, NULL, 'hr', 'external', NULL, NULL, NULL, NULL, 'active', '2018-03-01 10:31:19', 2, NULL),
(32, 'admin', 'candidate10@gmail.com', 'd033e22ae348aeb5660fc2140aec35850c4da997', 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpb24iOiJhY2NvdW50LWFjdGl2YXRlIiwidXNlcl90eXBlIjoiY2FuZGlkYXRlIiwidXNlcl9pZCI6MzIsImlhdCI6MTUyMjIzODQ0MywiZXhwIjoxNTUzNzkyNDQzfQ.K0Sm06ms6neE-1yLG5qmHQ5O4hM77xHcO6sket9Q3po0V_QlvQ3kT3Zkf2A8krDAyrVu_KqOJtogCLyRsHFnrVhq32JFxwsrSHeCXPF7IPMzuhxHKoiy4BRgUwIyU51MvHauEb-aLhiRD-1w7-0D7451orkvQdENZyWnQ6klSnxwokWq_A40WQCW6-urUReGivnaduF1LnEiGJLQr_ZzP6SAcxIdQlNY70R0dbLpw3P0fUpACXH_ZtUo_PvwRr7qrRO_VVIGnhYngQEZOxuP_CH6t1Uz2rCHgsjH_67dkPrIgJ_6msLhqpZW-cgl-e12bCs-FOO8KTLunxG37GLA8A', 'candidate', '10', '+91.9786867675', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-28 12:00:43', 26, '2018-03-28 12:11:41'),
(33, 'admin', 'aashwinishinde324@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'a122', '12122', NULL, NULL, NULL, NULL, 'organization', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-29 11:41:47', 4, '2018-04-02 12:53:11'),
(34, 'admin', 'new_candidate@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'new', 'cand', '+91.9789787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:13:38', 20, NULL),
(35, 'admin', 'candy@g.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'new', 'candy', '+91.8787878787', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:17:18', 20, NULL),
(36, 'admin', 'candy2@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'New', 'Cnady', '+91.4545455534', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:20:19', 20, NULL),
(37, 'admin', 'we@g.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'wer', 'ewr', '+91.3534534555', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:36:05', 20, NULL),
(38, 'admin', 'can@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'can', '1', '+91.9789898947', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:42:07', 20, NULL),
(39, 'admin', 'sd@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'fds', 'sd', '+91.4545454559', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:42:57', 20, NULL),
(40, 'admin', 'asd@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'asd', 'asd', '+91.9789899883', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 10:47:04', 20, NULL),
(41, 'admin', 'v@g.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ghj', 'ghjhg', '+91.6545654656', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 11:15:03', 20, NULL),
(42, 'admin', '23@g.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ghj', 'ghj', '+91.5645654656', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 11:15:52', 20, NULL),
(43, 'admin', 'dfgd@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfg', 'fdg', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, '3535', NULL, 'active', '2018-03-30 11:16:34', 20, NULL),
(44, 'admin', 'sd@gm4ail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dsf', 'sdf', '+91.4353455455', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-03-30 11:18:05', 20, NULL),
(45, 'admin', 'new@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'NEw', 'user', NULL, NULL, NULL, NULL, 'organization', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 06:54:58', 1, NULL),
(46, 'admin', 'can2_user2@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'Externl', 'Can', '+91.7878787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 09:56:48', 23, NULL),
(47, 'admin', 'aashwinishinde244@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'Ashwini', 'R', '+91.9769632991', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 12:53:13', 20, '2018-04-02 12:54:37'),
(48, 'admin', 'aashwinishinde24e@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'Ash', 'R', '+91.9769632991', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 12:54:55', 20, '2018-04-02 12:56:10'),
(49, 'admin', 'aashwinishinde244@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'a', 'a', '+91.9769632991', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 12:56:23', 20, '2018-04-02 13:16:51'),
(50, 'admin', 'aashwinishinde254@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'a', 'a', '+91.6464564564', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 12:57:38', 3, NULL),
(51, 'admin', 'sdf@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'sdf', 'sdf', '+91.4545454545', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:07:12', 3, NULL),
(52, 'admin', 'ff@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'fdg', 'dfg', '+91.7878787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:09:25', 3, NULL),
(53, 'admin', 'asa@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'asa', 'asas', '+91.7878787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:10:21', 3, NULL),
(54, 'admin', 'asd@gma3il.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'asd', 'asd', '+91.7878787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:13:18', 3, NULL),
(55, 'admin', 'ashwini.rewatkar@v2solutions.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dsf', 'sdf', '+91.8898988989', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:14:04', 3, NULL),
(56, 'admin', 'aashwinishinde244@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfds', 'dsf', '+91.7878787878', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:17:02', 3, '2018-04-02 13:22:03'),
(57, 'admin', 'aashwinishinde2445@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfdsf', 'dfgd', '+91.8898989898', NULL, NULL, NULL, 'candidate', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:22:06', 3, '2018-04-02 13:24:04'),
(58, 'admin', 'aashwinishinde244@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'sdf', 'sdf', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:24:16', 3, '2018-04-02 13:27:25'),
(59, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:27:33', 3, '2018-04-02 13:28:32'),
(60, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:28:41', 3, '2018-04-02 13:30:01'),
(61, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '3', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:30:09', 3, '2018-04-02 13:31:32'),
(62, 'admin', 'aashwinishind5e24@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '4', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:31:40', 3, '2018-04-02 13:32:14'),
(63, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '5', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:32:25', 3, '2018-04-02 13:35:47'),
(64, 'admin', 'aashwinishinde244@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '7', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-02 13:36:47', 3, '2018-04-03 11:31:05'),
(65, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '10', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:31:07', 3, '2018-04-03 11:32:33'),
(66, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '11', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:32:42', 3, '2018-04-03 11:36:39'),
(67, 'admin', 'aashwinishinde524@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '12', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:36:53', 3, '2018-04-03 11:45:28'),
(68, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'asas', 'asd', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:45:36', 3, '2018-04-03 11:46:15'),
(69, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'asa', 'asassassa', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:46:19', 3, '2018-04-03 11:48:31'),
(70, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'sdf', 'sd', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:48:38', 3, '2018-04-03 11:49:17'),
(71, 'admin', 'aashwinishinde24@gmail.comt', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'df', 'fg', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:49:25', 3, '2018-04-03 11:50:22'),
(72, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'a', 'a', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:50:31', 3, '2018-04-03 11:51:26'),
(73, 'admin', 'aashwinishinde24@gmail.com45', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ac', 'as', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:51:28', 3, '2018-04-03 11:53:55'),
(74, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfg', 'df', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:54:02', 3, '2018-04-03 11:56:27'),
(75, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'aasas', 'asas', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 11:56:31', 3, '2018-04-03 12:02:40'),
(77, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'sa', 'asd', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:06:07', 3, '2018-04-03 12:07:47'),
(78, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'f', 'df', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:07:56', 3, '2018-04-03 12:37:55'),
(79, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'df', 'fd', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:38:02', 20, '2018-04-03 12:39:56'),
(80, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ds', 'sdf', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:40:03', 20, '2018-04-03 12:42:39'),
(81, 'admin', 'aashwinishinde24@gmail.come', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfg', 'fdg', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, '3535', NULL, 'active', '2018-04-03 12:42:43', 20, '2018-04-03 12:44:23'),
(82, 'admin', 'aashwinishinde24@gmail.com6', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:44:35', 20, '2018-04-03 12:45:07'),
(83, 'admin', 'aashwinishinde24@gmail.comr', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'dfg', 'fdg', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, '3535', NULL, 'active', '2018-04-03 12:45:12', 20, '2018-04-03 12:49:20'),
(84, 'admin', 'aashwinishinde24@gmail.com4', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'sdf', 'sd', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-03 12:49:35', 20, '2018-04-04 06:42:43'),
(85, 'admin', 'hr_new@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'Hr', 'New', NULL, NULL, NULL, NULL, 'hr', 'internal', NULL, NULL, NULL, 0, 'active', '2018-04-04 06:10:42', 3, NULL),
(86, 'admin', 'aashwinishinde24@gmail.com5', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'ibm', 'interviewer1', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-04 06:42:51', 20, '2018-04-04 06:45:53'),
(87, 'admin', 'aashwinishinde24@gmail.com', '23d42f5f3f66498b2c8ff4c20b8c5ac826e47146', NULL, 'int', '2', NULL, NULL, NULL, NULL, 'interviewer', NULL, NULL, NULL, NULL, NULL, 'active', '2018-04-04 06:46:21', 20, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_candidate`
--

CREATE TABLE `users_candidate` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `marital_status` varchar(50) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  `functional_area_id` int(11) DEFAULT NULL,
  `job_role` varchar(255) DEFAULT NULL,
  `key_skills` varchar(500) DEFAULT NULL,
  `current_location` int(11) DEFAULT NULL,
  `preferred_location` varchar(100) DEFAULT NULL,
  `total_exp` decimal(5,1) DEFAULT '0.0',
  `notice_period` tinyint(4) DEFAULT NULL,
  `serving_notice` tinyint(4) NOT NULL DEFAULT '0',
  `serving_notice_date` date DEFAULT NULL,
  `notice_period_negotiable` tinyint(4) DEFAULT NULL,
  `current_ctc` decimal(5,2) DEFAULT NULL,
  `resume_headline` varchar(255) DEFAULT NULL,
  `resume_summary` text,
  `cover_letter` varchar(500) DEFAULT NULL,
  `include_coverletter` tinyint(1) DEFAULT '0',
  `progress_value` tinyint(4) DEFAULT '0',
  `address` varchar(500) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `pincode` varchar(10) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_candidate`
--

INSERT INTO `users_candidate` (`id`, `user_id`, `marital_status`, `industry_id`, `functional_area_id`, `job_role`, `key_skills`, `current_location`, `preferred_location`, `total_exp`, `notice_period`, `serving_notice`, `serving_notice_date`, `notice_period_negotiable`, `current_ctc`, `resume_headline`, `resume_summary`, `cover_letter`, `include_coverletter`, `progress_value`, `address`, `country_id`, `pincode`, `created`, `modified`) VALUES
(1, 4, 'single', 6, 399, 'Sr analyst', 'fdsf', 190, 'Aizawl', '0.0', 15, 0, '0000-00-00', 0, '1.03', NULL, NULL, NULL, 0, 85, NULL, 3, '2145555', '2018-03-01 10:03:03', '2018-04-02 14:47:10'),
(2, 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:03:39', NULL),
(3, 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:06:44', NULL),
(4, 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:06:52', NULL),
(5, 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:06:59', NULL),
(6, 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:07:54', NULL),
(7, 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:08:03', NULL),
(8, 11, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-01 10:08:10', NULL),
(9, 32, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-28 12:00:43', NULL),
(10, 34, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:13:38', NULL),
(11, 35, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:17:18', NULL),
(12, 36, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:20:19', NULL),
(13, 37, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:36:05', NULL),
(14, 38, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:42:07', NULL),
(15, 39, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:42:57', NULL),
(16, 40, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 10:47:04', NULL),
(17, 41, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 11:15:03', NULL),
(18, 42, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 11:15:52', NULL),
(19, 44, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-03-30 11:18:05', NULL),
(20, 46, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 09:56:48', NULL),
(21, 47, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 12:53:13', NULL),
(22, 48, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 12:54:55', NULL),
(23, 49, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 12:56:23', NULL),
(24, 50, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 12:57:38', NULL),
(25, 51, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:07:12', NULL),
(26, 52, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:09:25', NULL),
(27, 53, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:10:21', NULL),
(28, 54, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:13:18', NULL),
(29, 55, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:14:04', NULL),
(30, 56, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:17:02', NULL),
(31, 57, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0.0', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, 5, NULL, NULL, NULL, '2018-04-02 13:22:06', NULL);

--
-- Triggers `users_candidate`
--
DELIMITER $$
CREATE TRIGGER `col_update_candidate_modified` AFTER UPDATE ON `users_candidate` FOR EACH ROW UPDATE users SET modified=NEW.modified
WHERE id=NEW.user_id
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users_certifications`
--

CREATE TABLE `users_certifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `certification_name` varchar(255) NOT NULL,
  `month_from` tinyint(4) NOT NULL,
  `year_from` smallint(6) NOT NULL,
  `month_to` tinyint(4) NOT NULL,
  `year_to` smallint(6) NOT NULL,
  `valid_till` smallint(6) NOT NULL,
  `training_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_certifications`
--

INSERT INTO `users_certifications` (`id`, `user_id`, `certification_name`, `month_from`, `year_from`, `month_to`, `year_to`, `valid_till`, `training_id`, `created`, `modified`) VALUES
(1, 4, 'hjg', 3, 1983, 5, 1986, 1994, 3, '2018-03-28 11:39:25', '2018-03-28 11:40:12');

-- --------------------------------------------------------

--
-- Table structure for table `users_educations`
--

CREATE TABLE `users_educations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `institute_name` varchar(255) DEFAULT NULL,
  `year_from` smallint(6) NOT NULL,
  `year_to` smallint(6) NOT NULL,
  `degree_id` int(11) DEFAULT NULL,
  `specialization_id` int(11) DEFAULT NULL,
  `education_type` varchar(50) NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_educations`
--

INSERT INTO `users_educations` (`id`, `user_id`, `institute_name`, `year_from`, `year_to`, `degree_id`, `specialization_id`, `education_type`, `created`, `modified`) VALUES
(1, 4, 'hjhjk', 1986, 1989, 4, NULL, 'Part Time', '2018-03-28 08:59:53', '2018-03-28 09:21:14'),
(2, 4, 'klj', 1980, 1981, 16, NULL, 'Full Time', '2018-03-28 09:02:06', '2018-03-28 09:21:14');

-- --------------------------------------------------------

--
-- Table structure for table `users_jobs`
--

CREATE TABLE `users_jobs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_jobs`
--

INSERT INTO `users_jobs` (`id`, `user_id`, `job_id`, `created`) VALUES
(1, 4, 3, '2018-03-30 10:54:13');

-- --------------------------------------------------------

--
-- Table structure for table `users_job_details`
--

CREATE TABLE `users_job_details` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `job_type` varchar(50) DEFAULT NULL,
  `employee_type` varchar(50) DEFAULT NULL,
  `preferred_shift` varchar(50) DEFAULT NULL,
  `annual_salary` decimal(5,2) DEFAULT '0.00',
  `salary_type` varchar(50) NOT NULL,
  `work_permit` varchar(50) DEFAULT NULL,
  `other_countries` varchar(500) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_job_details`
--

INSERT INTO `users_job_details` (`id`, `user_id`, `job_type`, `employee_type`, `preferred_shift`, `annual_salary`, `salary_type`, `work_permit`, `other_countries`, `created`, `modified`) VALUES
(1, 4, 'permanent', 'full_time', NULL, '1.04', 'rupees', 'need_h1_visa', 'Andorra', '2018-03-28 11:45:00', NULL),
(2, 4, 'permanent', 'full_time', NULL, '1.04', 'rupees', 'need_h1_visa', 'Andorra', '2018-03-28 11:45:15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_languages`
--

CREATE TABLE `users_languages` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `language` varchar(100) DEFAULT NULL,
  `profenciency_level` tinyint(4) DEFAULT NULL,
  `is_read` int(11) DEFAULT NULL,
  `is_write` int(11) DEFAULT NULL,
  `is_speak` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_languages`
--

INSERT INTO `users_languages` (`id`, `user_id`, `language`, `profenciency_level`, `is_read`, `is_write`, `is_speak`, `created`, `modified`) VALUES
(1, 4, 'dffggf', 3, 1, 0, 0, '2018-03-28 11:45:00', '2018-03-28 11:45:15'),
(2, 4, 'dfgdfg', 1, 0, 1, 0, '2018-03-28 11:45:15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users_organizations`
--

CREATE TABLE `users_organizations` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `client_id` int(11) DEFAULT NULL,
  `client_vertical_id` int(11) DEFAULT NULL,
  `client_vertical_location_id` int(11) DEFAULT NULL,
  `job_id` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_organizations`
--

INSERT INTO `users_organizations` (`id`, `user_id`, `organization_id`, `client_id`, `client_vertical_id`, `client_vertical_location_id`, `job_id`, `created`, `created_by`) VALUES
(1, 1, 1, NULL, NULL, NULL, NULL, '2018-03-01 09:35:46', 1),
(2, 2, 2, NULL, NULL, NULL, NULL, '2018-03-01 09:37:15', 1),
(3, 3, 3, NULL, NULL, NULL, NULL, '2018-03-01 09:40:00', 1),
(4, 4, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:03:03', 3),
(5, 5, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:03:39', 3),
(6, 6, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:06:44', 3),
(7, 7, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:06:52', 3),
(8, 8, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:06:59', 3),
(9, 7, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:07:33', 2),
(10, 8, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:07:46', 2),
(11, 9, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:07:54', 2),
(12, 10, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:08:03', 2),
(13, 11, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:08:10', 2),
(14, 12, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:09:24', 2),
(15, 13, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:09:33', 2),
(16, 14, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:09:47', 2),
(17, 15, 2, NULL, NULL, NULL, NULL, '2018-03-01 10:09:54', 2),
(18, 16, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:10:38', 3),
(19, 17, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:10:45', 3),
(20, 18, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:10:58', 3),
(21, 19, 3, NULL, NULL, NULL, NULL, '2018-03-01 10:11:06', 3),
(22, 20, 3, 4, 12, 38, NULL, '2018-03-01 10:13:35', 3),
(25, 20, 3, 4, 12, 41, NULL, '2018-03-01 10:13:35', 3),
(26, 20, 3, 4, 12, 37, NULL, '2018-03-01 10:13:35', 3),
(27, 20, 3, 4, 12, 40, NULL, '2018-03-01 10:13:35', 3),
(28, 20, 3, 4, 13, 44, NULL, '2018-03-01 10:13:35', 3),
(29, 20, 3, 4, 13, 42, NULL, '2018-03-01 10:13:35', 3),
(30, 20, 3, 4, 13, 45, NULL, '2018-03-01 10:13:35', 3),
(31, 20, 3, 4, 13, 47, NULL, '2018-03-01 10:13:35', 3),
(32, 20, 3, 4, 13, 43, NULL, '2018-03-01 10:13:35', 3),
(33, 20, 3, 4, 13, 46, NULL, '2018-03-01 10:13:35', 3),
(34, 20, 3, 4, 14, 49, NULL, '2018-03-01 10:13:35', 3),
(35, 20, 3, 4, 14, 48, NULL, '2018-03-01 10:13:35', 3),
(36, 20, 3, 4, 14, 50, NULL, '2018-03-01 10:13:35', 3),
(37, 20, 3, 4, 15, 52, NULL, '2018-03-01 10:13:35', 3),
(38, 20, 3, 4, 15, 51, NULL, '2018-03-01 10:13:35', 3),
(39, 20, 3, 4, 16, 55, NULL, '2018-03-01 10:13:35', 3),
(40, 20, 3, 4, 16, 53, NULL, '2018-03-01 10:13:35', 3),
(41, 20, 3, 4, 16, 56, NULL, '2018-03-01 10:13:35', 3),
(42, 20, 3, 4, 16, 58, NULL, '2018-03-01 10:13:35', 3),
(43, 20, 3, 4, 16, 54, NULL, '2018-03-01 10:13:35', 3),
(44, 20, 3, 4, 16, 57, NULL, '2018-03-01 10:13:35', 3),
(45, 20, 3, 5, 17, 59, NULL, '2018-03-01 10:13:35', 3),
(47, 20, 3, 5, 17, 61, NULL, '2018-03-01 10:13:35', 3),
(48, 20, 3, 5, 17, 63, NULL, '2018-03-01 10:13:35', 3),
(49, 20, 3, 5, 17, 62, NULL, '2018-03-01 10:13:35', 3),
(50, 20, 3, 5, 18, 64, NULL, '2018-03-01 10:13:35', 3),
(51, 20, 3, 5, 18, 65, NULL, '2018-03-01 10:13:35', 3),
(52, 20, 3, 5, 18, 66, NULL, '2018-03-01 10:13:35', 3),
(53, 20, 3, 5, 18, 68, NULL, '2018-03-01 10:13:35', 3),
(54, 20, 3, 5, 18, 67, NULL, '2018-03-01 10:13:35', 3),
(55, 20, 3, 5, 19, 69, NULL, '2018-03-01 10:13:35', 3),
(56, 20, 3, 5, 19, 70, NULL, '2018-03-01 10:13:35', 3),
(57, 20, 3, 5, 19, 71, NULL, '2018-03-01 10:13:35', 3),
(58, 20, 3, 5, 19, 73, NULL, '2018-03-01 10:13:35', 3),
(59, 20, 3, 5, 19, 72, NULL, '2018-03-01 10:13:35', 3),
(60, 20, 3, 5, 20, 74, NULL, '2018-03-01 10:13:35', 3),
(61, 20, 3, 5, 20, 75, NULL, '2018-03-01 10:13:35', 3),
(62, 20, 3, 5, 20, 76, NULL, '2018-03-01 10:13:35', 3),
(63, 20, 3, 5, 20, 78, NULL, '2018-03-01 10:13:35', 3),
(64, 20, 3, 5, 20, 77, NULL, '2018-03-01 10:13:35', 3),
(65, 20, 3, 5, 21, 79, NULL, '2018-03-01 10:13:35', 3),
(66, 20, 3, 5, 21, 80, NULL, '2018-03-01 10:13:35', 3),
(67, 20, 3, 5, 21, 81, NULL, '2018-03-01 10:13:35', 3),
(68, 20, 3, 5, 21, 83, NULL, '2018-03-01 10:13:35', 3),
(69, 20, 3, 5, 21, 82, NULL, '2018-03-01 10:13:35', 3),
(70, 3, 3, 4, 12, 38, NULL, '2018-03-01 10:13:35', 3),
(73, 3, 3, 4, 12, 41, NULL, '2018-03-01 10:13:35', 3),
(74, 3, 3, 4, 12, 37, NULL, '2018-03-01 10:13:35', 3),
(75, 3, 3, 4, 13, 44, NULL, '2018-03-01 10:13:35', 3),
(76, 3, 3, 4, 12, 40, NULL, '2018-03-01 10:13:35', 3),
(77, 3, 3, 4, 13, 45, NULL, '2018-03-01 10:13:35', 3),
(78, 3, 3, 4, 13, 42, NULL, '2018-03-01 10:13:35', 3),
(79, 3, 3, 4, 13, 47, NULL, '2018-03-01 10:13:35', 3),
(80, 3, 3, 4, 13, 43, NULL, '2018-03-01 10:13:35', 3),
(81, 3, 3, 4, 13, 46, NULL, '2018-03-01 10:13:35', 3),
(82, 3, 3, 4, 14, 49, NULL, '2018-03-01 10:13:35', 3),
(83, 3, 3, 4, 14, 48, NULL, '2018-03-01 10:13:35', 3),
(84, 3, 3, 4, 15, 52, NULL, '2018-03-01 10:13:35', 3),
(85, 3, 3, 4, 14, 50, NULL, '2018-03-01 10:13:35', 3),
(86, 3, 3, 4, 15, 51, NULL, '2018-03-01 10:13:35', 3),
(87, 3, 3, 4, 16, 55, NULL, '2018-03-01 10:13:35', 3),
(88, 3, 3, 4, 16, 53, NULL, '2018-03-01 10:13:35', 3),
(89, 3, 3, 4, 16, 56, NULL, '2018-03-01 10:13:35', 3),
(90, 3, 3, 4, 16, 58, NULL, '2018-03-01 10:13:35', 3),
(91, 3, 3, 4, 16, 57, NULL, '2018-03-01 10:13:35', 3),
(92, 3, 3, 4, 16, 54, NULL, '2018-03-01 10:13:35', 3),
(93, 3, 3, 5, 17, 59, NULL, '2018-03-01 10:13:35', 3),
(96, 3, 3, 5, 17, 63, NULL, '2018-03-01 10:13:35', 3),
(97, 3, 3, 5, 18, 64, NULL, '2018-03-01 10:13:35', 3),
(98, 3, 3, 5, 17, 62, NULL, '2018-03-01 10:13:35', 3),
(99, 3, 3, 5, 18, 65, NULL, '2018-03-01 10:13:35', 3),
(100, 3, 3, 5, 18, 66, NULL, '2018-03-01 10:13:35', 3),
(101, 3, 3, 5, 18, 68, NULL, '2018-03-01 10:13:35', 3),
(102, 3, 3, 5, 19, 69, NULL, '2018-03-01 10:13:35', 3),
(103, 3, 3, 5, 18, 67, NULL, '2018-03-01 10:13:35', 3),
(104, 3, 3, 5, 19, 70, NULL, '2018-03-01 10:13:35', 3),
(105, 3, 3, 5, 19, 71, NULL, '2018-03-01 10:13:35', 3),
(106, 3, 3, 5, 19, 73, NULL, '2018-03-01 10:13:35', 3),
(107, 3, 3, 5, 19, 72, NULL, '2018-03-01 10:13:35', 3),
(108, 3, 3, 5, 20, 74, NULL, '2018-03-01 10:13:35', 3),
(109, 3, 3, 5, 20, 75, NULL, '2018-03-01 10:13:35', 3),
(110, 3, 3, 5, 20, 76, NULL, '2018-03-01 10:13:35', 3),
(111, 3, 3, 5, 20, 78, NULL, '2018-03-01 10:13:35', 3),
(112, 3, 3, 5, 20, 77, NULL, '2018-03-01 10:13:35', 3),
(113, 3, 3, 5, 21, 80, NULL, '2018-03-01 10:13:35', 3),
(114, 3, 3, 5, 21, 79, NULL, '2018-03-01 10:13:35', 3),
(115, 3, 3, 5, 21, 81, NULL, '2018-03-01 10:13:35', 3),
(116, 3, 3, 5, 21, 82, NULL, '2018-03-01 10:13:35', 3),
(117, 3, 3, 5, 21, 83, NULL, '2018-03-01 10:13:35', 3),
(118, 21, 3, 4, 12, 38, NULL, '2018-03-01 10:14:23', 3),
(119, 21, 3, 4, 12, 36, NULL, '2018-03-01 10:14:23', 3),
(120, 21, 3, 4, 12, 39, NULL, '2018-03-01 10:14:23', 3),
(121, 21, 3, 4, 12, 41, NULL, '2018-03-01 10:14:23', 3),
(122, 21, 3, 4, 12, 37, NULL, '2018-03-01 10:14:23', 3),
(123, 21, 3, 4, 12, 40, NULL, '2018-03-01 10:14:23', 3),
(124, 21, 3, 4, 13, 44, NULL, '2018-03-01 10:14:23', 3),
(125, 21, 3, 4, 13, 42, NULL, '2018-03-01 10:14:23', 3),
(126, 21, 3, 4, 13, 45, NULL, '2018-03-01 10:14:23', 3),
(127, 21, 3, 4, 13, 47, NULL, '2018-03-01 10:14:23', 3),
(128, 21, 3, 4, 13, 43, NULL, '2018-03-01 10:14:23', 3),
(129, 21, 3, 4, 13, 46, NULL, '2018-03-01 10:14:23', 3),
(130, 21, 3, 4, 14, 49, NULL, '2018-03-01 10:14:23', 3),
(131, 21, 3, 4, 14, 48, NULL, '2018-03-01 10:14:23', 3),
(132, 21, 3, 4, 14, 50, NULL, '2018-03-01 10:14:23', 3),
(133, 21, 3, 4, 15, 52, NULL, '2018-03-01 10:14:23', 3),
(134, 21, 3, 4, 15, 51, NULL, '2018-03-01 10:14:23', 3),
(135, 21, 3, 4, 16, 55, NULL, '2018-03-01 10:14:23', 3),
(136, 21, 3, 4, 16, 53, NULL, '2018-03-01 10:14:23', 3),
(137, 21, 3, 4, 16, 56, NULL, '2018-03-01 10:14:23', 3),
(138, 21, 3, 4, 16, 58, NULL, '2018-03-01 10:14:23', 3),
(139, 21, 3, 4, 16, 54, NULL, '2018-03-01 10:14:23', 3),
(140, 21, 3, 4, 16, 57, NULL, '2018-03-01 10:14:23', 3),
(141, 21, 3, 5, 17, 59, NULL, '2018-03-01 10:14:23', 3),
(142, 21, 3, 5, 17, 60, NULL, '2018-03-01 10:14:23', 3),
(144, 21, 3, 5, 17, 63, NULL, '2018-03-01 10:14:23', 3),
(145, 21, 3, 5, 17, 62, NULL, '2018-03-01 10:14:23', 3),
(146, 21, 3, 5, 18, 64, NULL, '2018-03-01 10:14:23', 3),
(147, 21, 3, 5, 18, 65, NULL, '2018-03-01 10:14:23', 3),
(148, 21, 3, 5, 18, 66, NULL, '2018-03-01 10:14:23', 3),
(149, 21, 3, 5, 18, 68, NULL, '2018-03-01 10:14:23', 3),
(150, 21, 3, 5, 18, 67, NULL, '2018-03-01 10:14:23', 3),
(151, 21, 3, 5, 19, 69, NULL, '2018-03-01 10:14:23', 3),
(152, 21, 3, 5, 19, 70, NULL, '2018-03-01 10:14:23', 3),
(153, 21, 3, 5, 19, 71, NULL, '2018-03-01 10:14:23', 3),
(154, 21, 3, 5, 19, 73, NULL, '2018-03-01 10:14:23', 3),
(155, 21, 3, 5, 19, 72, NULL, '2018-03-01 10:14:23', 3),
(156, 21, 3, 5, 20, 74, NULL, '2018-03-01 10:14:23', 3),
(157, 21, 3, 5, 20, 75, NULL, '2018-03-01 10:14:23', 3),
(158, 21, 3, 5, 20, 76, NULL, '2018-03-01 10:14:23', 3),
(159, 21, 3, 5, 20, 78, NULL, '2018-03-01 10:14:23', 3),
(160, 21, 3, 5, 20, 77, NULL, '2018-03-01 10:14:23', 3),
(161, 21, 3, 5, 21, 79, NULL, '2018-03-01 10:14:23', 3),
(162, 21, 3, 5, 21, 80, NULL, '2018-03-01 10:14:23', 3),
(163, 21, 3, 5, 21, 81, NULL, '2018-03-01 10:14:23', 3),
(164, 21, 3, 5, 21, 83, NULL, '2018-03-01 10:14:23', 3),
(165, 21, 3, 5, 21, 82, NULL, '2018-03-01 10:14:23', 3),
(166, 22, 3, 4, 12, 38, NULL, '2018-03-01 10:15:16', 3),
(167, 22, 3, 4, 12, 36, NULL, '2018-03-01 10:15:16', 3),
(168, 22, 3, 4, 12, 39, NULL, '2018-03-01 10:15:16', 3),
(169, 22, 3, 4, 12, 41, NULL, '2018-03-01 10:15:16', 3),
(170, 22, 3, 4, 12, 37, NULL, '2018-03-01 10:15:16', 3),
(171, 22, 3, 4, 12, 40, NULL, '2018-03-01 10:15:16', 3),
(172, 22, 3, 4, 13, 44, NULL, '2018-03-01 10:15:16', 3),
(173, 22, 3, 4, 13, 42, NULL, '2018-03-01 10:15:16', 3),
(174, 22, 3, 4, 13, 45, NULL, '2018-03-01 10:15:16', 3),
(175, 22, 3, 4, 13, 47, NULL, '2018-03-01 10:15:16', 3),
(176, 22, 3, 4, 13, 43, NULL, '2018-03-01 10:15:16', 3),
(177, 22, 3, 4, 13, 46, NULL, '2018-03-01 10:15:16', 3),
(178, 22, 3, 4, 14, 49, NULL, '2018-03-01 10:15:16', 3),
(179, 22, 3, 4, 14, 48, NULL, '2018-03-01 10:15:16', 3),
(180, 22, 3, 4, 14, 50, NULL, '2018-03-01 10:15:16', 3),
(181, 22, 3, 4, 15, 52, NULL, '2018-03-01 10:15:16', 3),
(182, 22, 3, 4, 15, 51, NULL, '2018-03-01 10:15:16', 3),
(183, 22, 3, 4, 16, 55, NULL, '2018-03-01 10:15:16', 3),
(184, 22, 3, 4, 16, 53, NULL, '2018-03-01 10:15:16', 3),
(185, 22, 3, 4, 16, 56, NULL, '2018-03-01 10:15:16', 3),
(186, 22, 3, 4, 16, 58, NULL, '2018-03-01 10:15:16', 3),
(187, 22, 3, 4, 16, 54, NULL, '2018-03-01 10:15:16', 3),
(188, 22, 3, 4, 16, 57, NULL, '2018-03-01 10:15:16', 3),
(189, 22, 3, 5, 17, 59, NULL, '2018-03-01 10:15:16', 3),
(190, 22, 3, 5, 17, 60, NULL, '2018-03-01 10:15:16', 3),
(191, 22, 3, 5, 17, 61, NULL, '2018-03-01 10:15:16', 3),
(192, 22, 3, 5, 17, 63, NULL, '2018-03-01 10:15:16', 3),
(193, 22, 3, 5, 17, 62, NULL, '2018-03-01 10:15:16', 3),
(194, 22, 3, 5, 18, 64, NULL, '2018-03-01 10:15:16', 3),
(195, 22, 3, 5, 18, 65, NULL, '2018-03-01 10:15:16', 3),
(196, 22, 3, 5, 18, 66, NULL, '2018-03-01 10:15:16', 3),
(197, 22, 3, 5, 18, 68, NULL, '2018-03-01 10:15:16', 3),
(198, 22, 3, 5, 18, 67, NULL, '2018-03-01 10:15:16', 3),
(199, 22, 3, 5, 19, 69, NULL, '2018-03-01 10:15:16', 3),
(200, 22, 3, 5, 19, 70, NULL, '2018-03-01 10:15:16', 3),
(201, 22, 3, 5, 19, 71, NULL, '2018-03-01 10:15:16', 3),
(202, 22, 3, 5, 19, 73, NULL, '2018-03-01 10:15:16', 3),
(203, 22, 3, 5, 19, 72, NULL, '2018-03-01 10:15:16', 3),
(204, 22, 3, 5, 20, 74, NULL, '2018-03-01 10:15:16', 3),
(205, 22, 3, 5, 20, 75, NULL, '2018-03-01 10:15:16', 3),
(206, 22, 3, 5, 20, 76, NULL, '2018-03-01 10:15:16', 3),
(207, 22, 3, 5, 20, 78, NULL, '2018-03-01 10:15:16', 3),
(208, 22, 3, 5, 20, 77, NULL, '2018-03-01 10:15:16', 3),
(209, 22, 3, 5, 21, 79, NULL, '2018-03-01 10:15:16', 3),
(210, 22, 3, 5, 21, 80, NULL, '2018-03-01 10:15:16', 3),
(211, 22, 3, 5, 21, 81, NULL, '2018-03-01 10:15:16', 3),
(212, 22, 3, 5, 21, 83, NULL, '2018-03-01 10:15:16', 3),
(213, 22, 3, 5, 21, 82, NULL, '2018-03-01 10:15:16', 3),
(214, 23, 3, 4, 15, 52, NULL, '2018-03-01 10:17:09', 3),
(215, 23, 3, 4, 15, 51, NULL, '2018-03-01 10:17:09', 3),
(216, 23, 3, 4, 16, 55, NULL, '2018-03-01 10:17:09', 3),
(217, 23, 3, 4, 16, 53, NULL, '2018-03-01 10:17:09', 3),
(218, 23, 3, 4, 16, 56, NULL, '2018-03-01 10:17:09', 3),
(219, 23, 3, 4, 16, 58, NULL, '2018-03-01 10:17:09', 3),
(220, 23, 3, 4, 16, 54, NULL, '2018-03-01 10:17:09', 3),
(221, 23, 3, 4, 16, 57, NULL, '2018-03-01 10:17:09', 3),
(222, 24, 3, 4, 12, 38, NULL, '2018-03-01 10:17:49', 3),
(223, 24, 3, 4, 12, 36, NULL, '2018-03-01 10:17:49', 3),
(224, 24, 3, 4, 12, 39, NULL, '2018-03-01 10:17:49', 3),
(225, 24, 3, 4, 12, 41, NULL, '2018-03-01 10:17:49', 3),
(226, 24, 3, 4, 12, 37, NULL, '2018-03-01 10:17:49', 3),
(227, 24, 3, 4, 12, 40, NULL, '2018-03-01 10:17:49', 3),
(228, 24, 3, 4, 13, 44, NULL, '2018-03-01 10:17:49', 3),
(229, 24, 3, 4, 13, 42, NULL, '2018-03-01 10:17:49', 3),
(230, 24, 3, 4, 13, 45, NULL, '2018-03-01 10:17:49', 3),
(231, 24, 3, 4, 13, 47, NULL, '2018-03-01 10:17:49', 3),
(232, 24, 3, 4, 13, 43, NULL, '2018-03-01 10:17:49', 3),
(233, 24, 3, 4, 13, 46, NULL, '2018-03-01 10:17:49', 3),
(234, 24, 3, 4, 14, 49, NULL, '2018-03-01 10:17:49', 3),
(235, 24, 3, 4, 14, 48, NULL, '2018-03-01 10:17:49', 3),
(236, 24, 3, 4, 14, 50, NULL, '2018-03-01 10:17:49', 3),
(237, 24, 3, 4, 15, 52, NULL, '2018-03-01 10:17:49', 3),
(238, 24, 3, 4, 15, 51, NULL, '2018-03-01 10:17:49', 3),
(239, 24, 3, 4, 16, 55, NULL, '2018-03-01 10:17:49', 3),
(240, 24, 3, 4, 16, 53, NULL, '2018-03-01 10:17:49', 3),
(241, 24, 3, 4, 16, 56, NULL, '2018-03-01 10:17:49', 3),
(242, 24, 3, 4, 16, 58, NULL, '2018-03-01 10:17:49', 3),
(243, 24, 3, 4, 16, 54, NULL, '2018-03-01 10:17:49', 3),
(244, 24, 3, 4, 16, 57, NULL, '2018-03-01 10:17:49', 3),
(245, 24, 3, 5, 17, 59, NULL, '2018-03-01 10:17:49', 3),
(246, 24, 3, 5, 17, 60, NULL, '2018-03-01 10:17:49', 3),
(248, 24, 3, 5, 17, 63, NULL, '2018-03-01 10:17:49', 3),
(249, 24, 3, 5, 17, 62, NULL, '2018-03-01 10:17:49', 3),
(250, 24, 3, 5, 18, 64, NULL, '2018-03-01 10:17:49', 3),
(251, 24, 3, 5, 18, 65, NULL, '2018-03-01 10:17:49', 3),
(252, 24, 3, 5, 18, 66, NULL, '2018-03-01 10:17:49', 3),
(253, 24, 3, 5, 18, 68, NULL, '2018-03-01 10:17:49', 3),
(254, 24, 3, 5, 18, 67, NULL, '2018-03-01 10:17:49', 3),
(255, 24, 3, 5, 19, 69, NULL, '2018-03-01 10:17:49', 3),
(256, 24, 3, 5, 19, 70, NULL, '2018-03-01 10:17:49', 3),
(257, 24, 3, 5, 19, 71, NULL, '2018-03-01 10:17:49', 3),
(258, 24, 3, 5, 19, 73, NULL, '2018-03-01 10:17:49', 3),
(259, 24, 3, 5, 19, 72, NULL, '2018-03-01 10:17:49', 3),
(260, 24, 3, 5, 20, 74, NULL, '2018-03-01 10:17:49', 3),
(261, 24, 3, 5, 20, 75, NULL, '2018-03-01 10:17:49', 3),
(262, 24, 3, 5, 20, 76, NULL, '2018-03-01 10:17:49', 3),
(263, 24, 3, 5, 20, 78, NULL, '2018-03-01 10:17:49', 3),
(264, 24, 3, 5, 20, 77, NULL, '2018-03-01 10:17:49', 3),
(265, 24, 3, 5, 21, 79, NULL, '2018-03-01 10:17:49', 3),
(266, 24, 3, 5, 21, 80, NULL, '2018-03-01 10:17:49', 3),
(267, 24, 3, 5, 21, 81, NULL, '2018-03-01 10:17:49', 3),
(268, 24, 3, 5, 21, 83, NULL, '2018-03-01 10:17:49', 3),
(269, 24, 3, 5, 21, 82, NULL, '2018-03-01 10:17:49', 3),
(270, 25, 3, 5, 18, 64, NULL, '2018-03-01 10:18:46', 3),
(271, 25, 3, 5, 18, 65, NULL, '2018-03-01 10:18:46', 3),
(272, 25, 3, 5, 18, 66, NULL, '2018-03-01 10:18:46', 3),
(273, 25, 3, 5, 18, 68, NULL, '2018-03-01 10:18:46', 3),
(274, 25, 3, 5, 18, 67, NULL, '2018-03-01 10:18:46', 3),
(275, 25, 3, 5, 21, 79, NULL, '2018-03-01 10:18:46', 3),
(276, 25, 3, 5, 21, 80, NULL, '2018-03-01 10:18:46', 3),
(277, 25, 3, 5, 21, 81, NULL, '2018-03-01 10:18:46', 3),
(278, 25, 3, 5, 21, 83, NULL, '2018-03-01 10:18:46', 3),
(279, 25, 3, 5, 21, 82, NULL, '2018-03-01 10:18:46', 3),
(280, 26, 2, 2, 1, 1, NULL, '2018-03-01 10:26:03', 2),
(281, 26, 2, 2, 1, 2, NULL, '2018-03-01 10:26:03', 2),
(282, 26, 2, 2, 1, 3, NULL, '2018-03-01 10:26:03', 2),
(283, 26, 2, 2, 2, 5, NULL, '2018-03-01 10:26:03', 2),
(284, 26, 2, 2, 2, 4, NULL, '2018-03-01 10:26:03', 2),
(285, 26, 2, 2, 2, 6, NULL, '2018-03-01 10:26:03', 2),
(286, 26, 2, 2, 2, 7, NULL, '2018-03-01 10:26:03', 2),
(287, 26, 2, 2, 3, 8, NULL, '2018-03-01 10:26:03', 2),
(288, 26, 2, 2, 3, 9, NULL, '2018-03-01 10:26:03', 2),
(289, 26, 2, 2, 3, 10, NULL, '2018-03-01 10:26:03', 2),
(290, 26, 2, 2, 4, 12, NULL, '2018-03-01 10:26:03', 2),
(291, 26, 2, 2, 4, 11, NULL, '2018-03-01 10:26:03', 2),
(292, 26, 2, 2, 4, 13, NULL, '2018-03-01 10:26:03', 2),
(293, 26, 2, 2, 4, 14, NULL, '2018-03-01 10:26:03', 2),
(294, 26, 2, 2, 5, 16, NULL, '2018-03-01 10:26:03', 2),
(295, 26, 2, 2, 5, 15, NULL, '2018-03-01 10:26:03', 2),
(296, 26, 2, 2, 5, 17, NULL, '2018-03-01 10:26:03', 2),
(297, 26, 2, 2, 6, 18, NULL, '2018-03-01 10:26:03', 2),
(298, 26, 2, 2, 6, 19, NULL, '2018-03-01 10:26:03', 2),
(299, 26, 2, 3, 7, 20, NULL, '2018-03-01 10:26:03', 2),
(300, 26, 2, 3, 7, 21, NULL, '2018-03-01 10:26:03', 2),
(301, 26, 2, 3, 7, 22, NULL, '2018-03-01 10:26:03', 2),
(302, 26, 2, 3, 8, 24, NULL, '2018-03-01 10:26:03', 2),
(303, 26, 2, 3, 8, 23, NULL, '2018-03-01 10:26:03', 2),
(304, 26, 2, 3, 8, 25, NULL, '2018-03-01 10:26:03', 2),
(305, 26, 2, 3, 9, 27, NULL, '2018-03-01 10:26:03', 2),
(306, 26, 2, 3, 9, 26, NULL, '2018-03-01 10:26:03', 2),
(307, 26, 2, 3, 9, 28, NULL, '2018-03-01 10:26:03', 2),
(308, 26, 2, 3, 9, 29, NULL, '2018-03-01 10:26:03', 2),
(309, 26, 2, 3, 10, 30, NULL, '2018-03-01 10:26:03', 2),
(310, 26, 2, 3, 10, 31, NULL, '2018-03-01 10:26:03', 2),
(311, 26, 2, 3, 11, 33, NULL, '2018-03-01 10:26:03', 2),
(312, 26, 2, 3, 11, 32, NULL, '2018-03-01 10:26:03', 2),
(313, 26, 2, 3, 11, 34, NULL, '2018-03-01 10:26:03', 2),
(314, 26, 2, 3, 11, 35, NULL, '2018-03-01 10:26:03', 2),
(315, 2, 2, 2, 1, 1, NULL, '2018-03-01 10:26:03', 2),
(316, 2, 2, 2, 1, 2, NULL, '2018-03-01 10:26:03', 2),
(317, 2, 2, 2, 1, 3, NULL, '2018-03-01 10:26:03', 2),
(318, 2, 2, 2, 2, 5, NULL, '2018-03-01 10:26:03', 2),
(319, 2, 2, 2, 2, 4, NULL, '2018-03-01 10:26:03', 2),
(320, 2, 2, 2, 2, 6, NULL, '2018-03-01 10:26:03', 2),
(321, 2, 2, 2, 2, 7, NULL, '2018-03-01 10:26:03', 2),
(322, 2, 2, 2, 3, 8, NULL, '2018-03-01 10:26:03', 2),
(323, 2, 2, 2, 3, 9, NULL, '2018-03-01 10:26:03', 2),
(324, 2, 2, 2, 3, 10, NULL, '2018-03-01 10:26:03', 2),
(325, 2, 2, 2, 4, 12, NULL, '2018-03-01 10:26:03', 2),
(326, 2, 2, 2, 4, 11, NULL, '2018-03-01 10:26:03', 2),
(327, 2, 2, 2, 4, 13, NULL, '2018-03-01 10:26:03', 2),
(328, 2, 2, 2, 4, 14, NULL, '2018-03-01 10:26:03', 2),
(329, 2, 2, 2, 5, 16, NULL, '2018-03-01 10:26:03', 2),
(330, 2, 2, 2, 5, 15, NULL, '2018-03-01 10:26:03', 2),
(331, 2, 2, 2, 5, 17, NULL, '2018-03-01 10:26:03', 2),
(332, 2, 2, 2, 6, 18, NULL, '2018-03-01 10:26:03', 2),
(333, 2, 2, 2, 6, 19, NULL, '2018-03-01 10:26:03', 2),
(334, 2, 2, 3, 7, 20, NULL, '2018-03-01 10:26:03', 2),
(335, 2, 2, 3, 7, 21, NULL, '2018-03-01 10:26:03', 2),
(336, 2, 2, 3, 7, 22, NULL, '2018-03-01 10:26:03', 2),
(337, 2, 2, 3, 8, 24, NULL, '2018-03-01 10:26:03', 2),
(338, 2, 2, 3, 8, 23, NULL, '2018-03-01 10:26:03', 2),
(339, 2, 2, 3, 8, 25, NULL, '2018-03-01 10:26:03', 2),
(340, 2, 2, 3, 9, 27, NULL, '2018-03-01 10:26:03', 2),
(341, 2, 2, 3, 9, 26, NULL, '2018-03-01 10:26:03', 2),
(342, 2, 2, 3, 9, 28, NULL, '2018-03-01 10:26:03', 2),
(343, 2, 2, 3, 9, 29, NULL, '2018-03-01 10:26:03', 2),
(344, 2, 2, 3, 10, 30, NULL, '2018-03-01 10:26:03', 2),
(345, 2, 2, 3, 10, 31, NULL, '2018-03-01 10:26:03', 2),
(346, 2, 2, 3, 11, 33, NULL, '2018-03-01 10:26:03', 2),
(347, 2, 2, 3, 11, 32, NULL, '2018-03-01 10:26:03', 2),
(348, 2, 2, 3, 11, 34, NULL, '2018-03-01 10:26:03', 2),
(349, 2, 2, 3, 11, 35, NULL, '2018-03-01 10:26:03', 2),
(350, 27, 2, 2, 1, 1, NULL, '2018-03-01 10:27:28', 2),
(351, 27, 2, 2, 1, 2, NULL, '2018-03-01 10:27:28', 2),
(352, 27, 2, 2, 1, 3, NULL, '2018-03-01 10:27:28', 2),
(353, 27, 2, 2, 2, 5, NULL, '2018-03-01 10:27:28', 2),
(354, 27, 2, 2, 2, 4, NULL, '2018-03-01 10:27:28', 2),
(355, 27, 2, 2, 2, 6, NULL, '2018-03-01 10:27:28', 2),
(356, 27, 2, 2, 2, 7, NULL, '2018-03-01 10:27:28', 2),
(357, 27, 2, 2, 3, 8, NULL, '2018-03-01 10:27:28', 2),
(358, 27, 2, 2, 3, 9, NULL, '2018-03-01 10:27:28', 2),
(359, 27, 2, 2, 3, 10, NULL, '2018-03-01 10:27:28', 2),
(360, 27, 2, 2, 4, 12, NULL, '2018-03-01 10:27:28', 2),
(361, 27, 2, 2, 4, 11, NULL, '2018-03-01 10:27:28', 2),
(362, 27, 2, 2, 4, 13, NULL, '2018-03-01 10:27:28', 2),
(363, 27, 2, 2, 4, 14, NULL, '2018-03-01 10:27:28', 2),
(364, 27, 2, 2, 5, 16, NULL, '2018-03-01 10:27:28', 2),
(365, 27, 2, 2, 5, 15, NULL, '2018-03-01 10:27:28', 2),
(366, 27, 2, 2, 5, 17, NULL, '2018-03-01 10:27:28', 2),
(367, 27, 2, 2, 6, 18, NULL, '2018-03-01 10:27:28', 2),
(368, 27, 2, 2, 6, 19, NULL, '2018-03-01 10:27:28', 2),
(369, 27, 2, 3, 7, 20, NULL, '2018-03-01 10:27:28', 2),
(370, 27, 2, 3, 7, 21, NULL, '2018-03-01 10:27:28', 2),
(371, 27, 2, 3, 7, 22, NULL, '2018-03-01 10:27:28', 2),
(372, 27, 2, 3, 8, 24, NULL, '2018-03-01 10:27:28', 2),
(373, 27, 2, 3, 8, 23, NULL, '2018-03-01 10:27:28', 2),
(374, 27, 2, 3, 8, 25, NULL, '2018-03-01 10:27:28', 2),
(375, 27, 2, 3, 9, 27, NULL, '2018-03-01 10:27:28', 2),
(376, 27, 2, 3, 9, 26, NULL, '2018-03-01 10:27:28', 2),
(377, 27, 2, 3, 9, 28, NULL, '2018-03-01 10:27:28', 2),
(378, 27, 2, 3, 9, 29, NULL, '2018-03-01 10:27:28', 2),
(379, 27, 2, 3, 10, 30, NULL, '2018-03-01 10:27:28', 2),
(380, 27, 2, 3, 10, 31, NULL, '2018-03-01 10:27:28', 2),
(381, 27, 2, 3, 11, 33, NULL, '2018-03-01 10:27:28', 2),
(382, 27, 2, 3, 11, 32, NULL, '2018-03-01 10:27:28', 2),
(383, 27, 2, 3, 11, 34, NULL, '2018-03-01 10:27:28', 2),
(384, 27, 2, 3, 11, 35, NULL, '2018-03-01 10:27:28', 2),
(385, 28, 2, 2, 6, 18, NULL, '2018-03-01 10:29:21', 2),
(386, 28, 2, 2, 6, 19, NULL, '2018-03-01 10:29:21', 2),
(387, 29, 2, 2, 2, 5, NULL, '2018-03-01 10:30:06', 2),
(388, 29, 2, 2, 2, 4, NULL, '2018-03-01 10:30:06', 2),
(389, 29, 2, 2, 2, 6, NULL, '2018-03-01 10:30:06', 2),
(390, 29, 2, 2, 2, 7, NULL, '2018-03-01 10:30:06', 2),
(391, 30, 2, 3, 9, 27, NULL, '2018-03-01 10:30:51', 2),
(392, 30, 2, 3, 9, 26, NULL, '2018-03-01 10:30:51', 2),
(393, 30, 2, 3, 9, 28, NULL, '2018-03-01 10:30:51', 2),
(394, 30, 2, 3, 9, 29, NULL, '2018-03-01 10:30:51', 2),
(395, 31, 2, 3, 11, 34, NULL, '2018-03-01 10:31:19', 2),
(396, 31, 2, 3, 11, 35, NULL, '2018-03-01 10:31:19', 2),
(397, 20, 3, 5, 21, 63, 1, '2018-03-26 06:10:08', 20),
(398, 3, 3, 5, 21, 63, 1, '2018-03-26 06:10:08', 20),
(399, 24, 3, 5, 21, 61, 2, '2018-03-26 06:47:55', 24),
(400, 3, 3, 5, 21, 61, 2, '2018-03-26 06:47:55', 24),
(401, 21, 3, 5, 21, 61, 2, '2018-03-26 06:47:55', 24),
(402, 20, 3, 4, 16, 39, 3, '2018-03-26 11:50:00', 20),
(403, 3, 3, 4, 16, 39, 3, '2018-03-26 11:50:00', 20),
(404, 20, 3, 5, 21, 60, 4, '2018-03-27 08:05:42', 20),
(405, 3, 3, 5, 21, 60, 4, '2018-03-27 08:05:42', 20),
(406, 32, 2, NULL, NULL, NULL, NULL, '2018-03-28 12:00:43', 26),
(407, 33, 4, NULL, NULL, NULL, NULL, '2018-03-29 11:41:47', 4),
(408, 34, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:13:38', 20),
(409, 35, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:17:18', 20),
(410, 36, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:20:19', 20),
(411, 37, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:36:05', 20),
(412, 38, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:42:07', 20),
(413, 39, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:42:57', 20),
(414, 40, 3, NULL, NULL, NULL, NULL, '2018-03-30 10:47:04', 20),
(415, 41, 3, NULL, NULL, NULL, NULL, '2018-03-30 11:15:03', 20),
(416, 42, 3, NULL, NULL, NULL, NULL, '2018-03-30 11:15:52', 20),
(417, 43, 3, NULL, NULL, NULL, NULL, '2018-03-30 11:16:34', 20),
(418, 44, 3, NULL, NULL, NULL, NULL, '2018-03-30 11:18:05', 20),
(419, 45, 5, NULL, NULL, NULL, NULL, '2018-04-02 06:54:58', 1),
(420, 46, 3, NULL, NULL, NULL, NULL, '2018-04-02 09:56:48', 23),
(421, 33, 3, NULL, NULL, NULL, NULL, '2018-04-02 12:50:47', 20),
(422, 47, 3, NULL, NULL, NULL, NULL, '2018-04-02 12:53:13', 20),
(423, 48, 3, NULL, NULL, NULL, NULL, '2018-04-02 12:54:55', 20),
(424, 49, 3, NULL, NULL, NULL, NULL, '2018-04-02 12:56:23', 20),
(425, 50, 3, NULL, NULL, NULL, NULL, '2018-04-02 12:57:38', 3),
(426, 51, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:07:12', 3),
(427, 52, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:09:25', 3),
(428, 53, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:10:21', 3),
(429, 54, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:13:18', 3),
(430, 55, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:14:04', 3),
(431, 56, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:17:02', 3),
(432, 57, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:22:06', 3),
(433, 58, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:24:16', 3),
(434, 59, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:27:33', 3),
(435, 60, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:28:41', 3),
(436, 61, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:30:09', 3),
(437, 62, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:31:40', 3),
(438, 63, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:32:25', 3),
(439, 64, 3, NULL, NULL, NULL, NULL, '2018-04-02 13:36:47', 3),
(440, 65, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:31:07', 3),
(441, 66, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:32:42', 3),
(442, 67, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:36:53', 3),
(443, 68, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:45:36', 3),
(444, 69, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:46:19', 3),
(445, 70, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:48:38', 3),
(446, 71, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:49:25', 3),
(447, 72, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:50:31', 3),
(448, 73, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:51:28', 3),
(449, 74, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:54:02', 3),
(450, 75, 3, NULL, NULL, NULL, NULL, '2018-04-03 11:56:31', 3),
(452, 77, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:06:07', 3),
(453, 78, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:07:56', 3),
(454, 79, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:38:02', 20),
(455, 80, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:40:03', 20),
(456, 81, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:42:44', 20),
(457, 82, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:44:35', 20),
(458, 83, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:45:12', 20),
(459, 84, 3, NULL, NULL, NULL, NULL, '2018-04-03 12:49:35', 20),
(460, 85, 3, 4, 12, 36, NULL, '2018-04-04 06:10:42', 3),
(461, 85, 3, 4, 12, 37, NULL, '2018-04-04 06:10:42', 3),
(462, 85, 3, 4, 14, 48, NULL, '2018-04-04 06:10:42', 3),
(463, 85, 3, 5, 18, 64, NULL, '2018-04-04 06:10:42', 3),
(464, 85, 3, 5, 18, 65, NULL, '2018-04-04 06:10:42', 3),
(465, 85, 3, 5, 18, 66, NULL, '2018-04-04 06:10:42', 3),
(466, 85, 3, 5, 18, 68, NULL, '2018-04-04 06:10:42', 3),
(467, 85, 3, 5, 18, 67, NULL, '2018-04-04 06:10:42', 3),
(468, 85, 3, 5, 20, 74, NULL, '2018-04-04 06:10:42', 3),
(469, 85, 3, 5, 20, 75, NULL, '2018-04-04 06:10:42', 3),
(470, 3, 3, 4, 12, 36, NULL, '2018-04-04 06:10:43', 3),
(471, 86, 3, NULL, NULL, NULL, NULL, '2018-04-04 06:42:51', 20),
(472, 87, 3, NULL, NULL, NULL, NULL, '2018-04-04 06:46:21', 20);

-- --------------------------------------------------------

--
-- Table structure for table `users_professions`
--

CREATE TABLE `users_professions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `employer_name` varchar(255) NOT NULL,
  `designation_id` int(11) NOT NULL,
  `month_from` tinyint(4) NOT NULL,
  `month_to` tinyint(4) NOT NULL,
  `year_from` smallint(6) DEFAULT NULL,
  `year_to` smallint(6) DEFAULT NULL,
  `is_current_employer` tinyint(4) DEFAULT '0',
  `skills` varchar(500) NOT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_professions`
--

INSERT INTO `users_professions` (`id`, `user_id`, `employer_name`, `designation_id`, `month_from`, `month_to`, `year_from`, `year_to`, `is_current_employer`, `skills`, `created`, `modified`) VALUES
(1, 4, 'vbcvb', 25, 2, 2, 1980, 1981, 0, '', '2018-03-28 09:58:33', '2018-03-28 10:25:33'),
(2, 4, 'gfh', 13, 2, 2, 1981, 1983, 0, '', '2018-03-28 10:24:37', '2018-03-28 10:25:33'),
(3, 4, 'sdfsd', 12, 2, 2, 1994, 1997, 1, '', '2018-03-28 10:25:26', '2018-03-28 10:25:33');

-- --------------------------------------------------------

--
-- Table structure for table `users_reporting`
--

CREATE TABLE `users_reporting` (
  `id` int(11) NOT NULL,
  `parent_user_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `lft` int(11) NOT NULL,
  `rht` int(11) NOT NULL,
  `lvl` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_reporting`
--

INSERT INTO `users_reporting` (`id`, `parent_user_id`, `user_id`, `lft`, `rht`, `lvl`) VALUES
(1, NULL, NULL, 1, 36, 0),
(2, NULL, 2, 2, 15, 1),
(3, NULL, 3, 16, 31, 1),
(4, 3, 20, 17, 22, 2),
(5, 3, 21, 23, 28, 2),
(6, 20, 22, 18, 19, 3),
(7, 20, 23, 20, 21, 3),
(8, 21, 24, 24, 25, 3),
(9, 21, 25, 26, 27, 3),
(10, 2, 26, 3, 8, 2),
(11, 2, 27, 9, 14, 2),
(12, 26, 28, 4, 5, 3),
(13, 26, 29, 6, 7, 3),
(14, 27, 30, 10, 11, 3),
(15, 27, 31, 12, 13, 3),
(16, NULL, 33, 32, 33, 1),
(17, NULL, 45, 34, 35, 1),
(18, 3, 85, 29, 30, 2);

-- --------------------------------------------------------

--
-- Table structure for table `users_resumes`
--

CREATE TABLE `users_resumes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `file_name` varchar(500) DEFAULT NULL,
  `is_primary` int(11) DEFAULT NULL,
  `is_secondary` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users_skills`
--

CREATE TABLE `users_skills` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `version` varchar(50) DEFAULT NULL,
  `experience` varchar(255) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  `modified` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `users_skills`
--

INSERT INTO `users_skills` (`id`, `user_id`, `name`, `version`, `experience`, `created`, `modified`) VALUES
(1, 4, 'dssdf', '', '1', '2018-03-28 10:46:07', '2018-03-28 16:16:21'),
(2, 4, 'dfgdfg', '', '4', '2018-03-28 10:46:21', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_user`
--
ALTER TABLE `admin_user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `admin_id` (`admin_id`);

--
-- Indexes for table `clients`
--
ALTER TABLE `clients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `organization_id_2` (`organization_id`,`name`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `clients_verticals`
--
ALTER TABLE `clients_verticals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `client_id_2` (`client_id`,`name`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `clients_verticals_locations`
--
ALTER TABLE `clients_verticals_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `client_vertical_id` (`client_vertical_id`,`client_location_id`),
  ADD KEY `client_location_id` (`client_location_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `interviews`
--
ALTER TABLE `interviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_application_id` (`job_application_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `interviewer_id` (`interviewer_id`) USING BTREE;

--
-- Indexes for table `interviews_feedback`
--
ALTER TABLE `interviews_feedback`
  ADD PRIMARY KEY (`id`),
  ADD KEY `interview_id` (`interview_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `interviews_feedback_core_skills`
--
ALTER TABLE `interviews_feedback_core_skills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `interview_feedback_id` (`interview_feedback_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `industry_id` (`industry_id`),
  ADD KEY `functional_area_id` (`functional_area_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`),
  ADD KEY `client_id` (`client_id`),
  ADD KEY `owner_id` (`owner_id`);

--
-- Indexes for table `jobs_applications`
--
ALTER TABLE `jobs_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`),
  ADD KEY `internal_hr_id` (`internal_hr_id`) USING BTREE,
  ADD KEY `external_hr_id` (`external_hr_id`) USING BTREE,
  ADD KEY `interviewer_id` (`interviewer_id`) USING BTREE;

--
-- Indexes for table `jobs_applications_comments`
--
ALTER TABLE `jobs_applications_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `job_application_id` (`job_application_id`);

--
-- Indexes for table `jobs_desired_degrees`
--
ALTER TABLE `jobs_desired_degrees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `degree_id` (`degree_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `jobs_hr`
--
ALTER TABLE `jobs_hr`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `hr_id` (`hr_id`),
  ADD KEY `jobs_hr_key_3` (`created_by`);

--
-- Indexes for table `jobs_interviewers`
--
ALTER TABLE `jobs_interviewers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `interviewer_id` (`interviewer_id`) USING BTREE;

--
-- Indexes for table `jobs_locations`
--
ALTER TABLE `jobs_locations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `location_id` (`location_id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `jobs_users`
--
ALTER TABLE `jobs_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_id_2` (`job_id`,`user_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `job_id` (`job_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `job_sent_by` (`job_sent_by`);

--
-- Indexes for table `logs`
--
ALTER TABLE `logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `masters_cities`
--
ALTER TABLE `masters_cities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `country_id` (`country_id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_countries`
--
ALTER TABLE `masters_countries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_degrees`
--
ALTER TABLE `masters_degrees`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_designations`
--
ALTER TABLE `masters_designations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_email_templates`
--
ALTER TABLE `masters_email_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_functional_areas`
--
ALTER TABLE `masters_functional_areas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_industries`
--
ALTER TABLE `masters_industries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_institutes`
--
ALTER TABLE `masters_institutes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_job_roles`
--
ALTER TABLE `masters_job_roles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_keywords`
--
ALTER TABLE `masters_keywords`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `name_2` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `masters_specializations`
--
ALTER TABLE `masters_specializations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`),
  ADD KEY `degree_id` (`degree_id`) USING BTREE;

--
-- Indexes for table `masters_trainings`
--
ALTER TABLE `masters_trainings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `name` (`name`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `organizations`
--
ALTER TABLE `organizations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`) USING BTREE,
  ADD KEY `created_by` (`created_by`),
  ADD KEY `modified_by` (`modified_by`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `organizations_settings`
--
ALTER TABLE `organizations_settings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `organization_id` (`organization_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email` (`email`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `users_candidate`
--
ALTER TABLE `users_candidate`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `functional_area_id` (`functional_area_id`),
  ADD KEY `industry_id` (`industry_id`);

--
-- Indexes for table `users_certifications`
--
ALTER TABLE `users_certifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `training_id` (`training_id`);

--
-- Indexes for table `users_educations`
--
ALTER TABLE `users_educations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `specialization_id` (`specialization_id`),
  ADD KEY `degree_id` (`degree_id`) USING BTREE;

--
-- Indexes for table `users_jobs`
--
ALTER TABLE `users_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_id_2` (`job_id`,`user_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `users_job_details`
--
ALTER TABLE `users_job_details`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users_languages`
--
ALTER TABLE `users_languages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users_organizations`
--
ALTER TABLE `users_organizations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `client_vertical_id` (`client_vertical_id`),
  ADD KEY `client_vertical_location_id` (`client_vertical_location_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `client_id` (`client_id`) USING BTREE,
  ADD KEY `user_id` (`user_id`),
  ADD KEY `organization_id` (`organization_id`),
  ADD KEY `job_id` (`job_id`);

--
-- Indexes for table `users_professions`
--
ALTER TABLE `users_professions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `designation_id` (`designation_id`);

--
-- Indexes for table `users_reporting`
--
ALTER TABLE `users_reporting`
  ADD PRIMARY KEY (`id`),
  ADD KEY `trees_nav_idx` (`lft`,`rht`,`lvl`),
  ADD KEY `trees_name_idx` (`user_id`,`lvl`),
  ADD KEY `parent_user_id` (`parent_user_id`);

--
-- Indexes for table `users_resumes`
--
ALTER TABLE `users_resumes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users_skills`
--
ALTER TABLE `users_skills`
  ADD PRIMARY KEY (`id`),
  ADD KEY `used_id` (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_user`
--
ALTER TABLE `admin_user`
  MODIFY `id` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=413;
--
-- AUTO_INCREMENT for table `clients`
--
ALTER TABLE `clients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `clients_verticals`
--
ALTER TABLE `clients_verticals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;
--
-- AUTO_INCREMENT for table `clients_verticals_locations`
--
ALTER TABLE `clients_verticals_locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;
--
-- AUTO_INCREMENT for table `interviews`
--
ALTER TABLE `interviews`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT for table `interviews_feedback`
--
ALTER TABLE `interviews_feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `interviews_feedback_core_skills`
--
ALTER TABLE `interviews_feedback_core_skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `jobs_applications`
--
ALTER TABLE `jobs_applications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `jobs_applications_comments`
--
ALTER TABLE `jobs_applications_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `jobs_desired_degrees`
--
ALTER TABLE `jobs_desired_degrees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;
--
-- AUTO_INCREMENT for table `jobs_hr`
--
ALTER TABLE `jobs_hr`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
--
-- AUTO_INCREMENT for table `jobs_interviewers`
--
ALTER TABLE `jobs_interviewers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;
--
-- AUTO_INCREMENT for table `jobs_locations`
--
ALTER TABLE `jobs_locations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `jobs_users`
--
ALTER TABLE `jobs_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
--
-- AUTO_INCREMENT for table `logs`
--
ALTER TABLE `logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=175;
--
-- AUTO_INCREMENT for table `masters_cities`
--
ALTER TABLE `masters_cities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=215;
--
-- AUTO_INCREMENT for table `masters_countries`
--
ALTER TABLE `masters_countries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=242;
--
-- AUTO_INCREMENT for table `masters_degrees`
--
ALTER TABLE `masters_degrees`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;
--
-- AUTO_INCREMENT for table `masters_designations`
--
ALTER TABLE `masters_designations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;
--
-- AUTO_INCREMENT for table `masters_email_templates`
--
ALTER TABLE `masters_email_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `masters_functional_areas`
--
ALTER TABLE `masters_functional_areas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=813;
--
-- AUTO_INCREMENT for table `masters_industries`
--
ALTER TABLE `masters_industries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=57;
--
-- AUTO_INCREMENT for table `masters_institutes`
--
ALTER TABLE `masters_institutes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `masters_job_roles`
--
ALTER TABLE `masters_job_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `masters_keywords`
--
ALTER TABLE `masters_keywords`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT for table `masters_specializations`
--
ALTER TABLE `masters_specializations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=336;
--
-- AUTO_INCREMENT for table `masters_trainings`
--
ALTER TABLE `masters_trainings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;
--
-- AUTO_INCREMENT for table `organizations`
--
ALTER TABLE `organizations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `organizations_settings`
--
ALTER TABLE `organizations_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=796;
--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=88;
--
-- AUTO_INCREMENT for table `users_candidate`
--
ALTER TABLE `users_candidate`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT for table `users_certifications`
--
ALTER TABLE `users_certifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `users_educations`
--
ALTER TABLE `users_educations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `users_jobs`
--
ALTER TABLE `users_jobs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `users_job_details`
--
ALTER TABLE `users_job_details`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `users_languages`
--
ALTER TABLE `users_languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT for table `users_organizations`
--
ALTER TABLE `users_organizations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=473;
--
-- AUTO_INCREMENT for table `users_professions`
--
ALTER TABLE `users_professions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `users_reporting`
--
ALTER TABLE `users_reporting`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT for table `users_resumes`
--
ALTER TABLE `users_resumes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `users_skills`
--
ALTER TABLE `users_skills`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `clients`
--
ALTER TABLE `clients`
  ADD CONSTRAINT `clients_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `clients_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `clients_verticals`
--
ALTER TABLE `clients_verticals`
  ADD CONSTRAINT `clients_verticals_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clients_verticals_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `clients_verticals_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `clients_verticals_locations`
--
ALTER TABLE `clients_verticals_locations`
  ADD CONSTRAINT `clients_verticals_locations_ibfk_1` FOREIGN KEY (`client_vertical_id`) REFERENCES `clients_verticals` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `clients_verticals_locations_ibfk_2` FOREIGN KEY (`client_location_id`) REFERENCES `masters_cities` (`id`),
  ADD CONSTRAINT `clients_verticals_locations_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `interviews`
--
ALTER TABLE `interviews`
  ADD CONSTRAINT `interviews_ibfk_1` FOREIGN KEY (`job_application_id`) REFERENCES `jobs_applications` (`id`),
  ADD CONSTRAINT `interviews_ibfk_2` FOREIGN KEY (`interviewer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `interviews_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `interviews_feedback`
--
ALTER TABLE `interviews_feedback`
  ADD CONSTRAINT `interviews_feedback_ibfk_1` FOREIGN KEY (`interview_id`) REFERENCES `interviews` (`id`),
  ADD CONSTRAINT `interviews_feedback_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `interviews_feedback_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `interviews_feedback_core_skills`
--
ALTER TABLE `interviews_feedback_core_skills`
  ADD CONSTRAINT `interviews_feedback_core_skills_ibfk_1` FOREIGN KEY (`interview_feedback_id`) REFERENCES `interviews_feedback` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `interviews_feedback_core_skills_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `interviews_feedback_core_skills_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs`
--
ALTER TABLE `jobs`
  ADD CONSTRAINT `jobs_ibfk_2` FOREIGN KEY (`industry_id`) REFERENCES `masters_industries` (`id`),
  ADD CONSTRAINT `jobs_ibfk_3` FOREIGN KEY (`functional_area_id`) REFERENCES `masters_functional_areas` (`id`),
  ADD CONSTRAINT `jobs_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_ibfk_6` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_ibfk_7` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `jobs_ibfk_8` FOREIGN KEY (`owner_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_applications`
--
ALTER TABLE `jobs_applications`
  ADD CONSTRAINT `jobs_applications_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_4` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_5` FOREIGN KEY (`internal_hr_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_6` FOREIGN KEY (`external_hr_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_applications_ibfk_7` FOREIGN KEY (`interviewer_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_applications_comments`
--
ALTER TABLE `jobs_applications_comments`
  ADD CONSTRAINT `jobs_applications_comments_ibfk_1` FOREIGN KEY (`job_application_id`) REFERENCES `jobs_applications` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_applications_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_desired_degrees`
--
ALTER TABLE `jobs_desired_degrees`
  ADD CONSTRAINT `jobs_desired_degrees_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_desired_degrees_ibfk_2` FOREIGN KEY (`degree_id`) REFERENCES `masters_degrees` (`id`),
  ADD CONSTRAINT `jobs_desired_degrees_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_desired_degrees_ibfk_4` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_hr`
--
ALTER TABLE `jobs_hr`
  ADD CONSTRAINT `jobs_hr_key_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`),
  ADD CONSTRAINT `jobs_hr_key_2` FOREIGN KEY (`hr_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_hr_key_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_interviewers`
--
ALTER TABLE `jobs_interviewers`
  ADD CONSTRAINT `jobs_interviewers_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_interviewers_ibfk_2` FOREIGN KEY (`interviewer_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `jobs_interviewers_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `jobs_locations`
--
ALTER TABLE `jobs_locations`
  ADD CONSTRAINT `jobs_locations_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_locations_ibfk_2` FOREIGN KEY (`location_id`) REFERENCES `clients_verticals_locations` (`id`);

--
-- Constraints for table `jobs_users`
--
ALTER TABLE `jobs_users`
  ADD CONSTRAINT `jobs_users_ibfk_1` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `jobs_users_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `jobs_users_ibfk_4` FOREIGN KEY (`job_sent_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `logs`
--
ALTER TABLE `logs`
  ADD CONSTRAINT `logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `masters_cities`
--
ALTER TABLE `masters_cities`
  ADD CONSTRAINT `masters_cities_ibfk_1` FOREIGN KEY (`country_id`) REFERENCES `masters_countries` (`id`),
  ADD CONSTRAINT `masters_cities_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_cities_ibfk_3` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_countries`
--
ALTER TABLE `masters_countries`
  ADD CONSTRAINT `masters_countries_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_countries_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_degrees`
--
ALTER TABLE `masters_degrees`
  ADD CONSTRAINT `masters_degrees_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_degrees_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_designations`
--
ALTER TABLE `masters_designations`
  ADD CONSTRAINT `masters_designations_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_designations_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_email_templates`
--
ALTER TABLE `masters_email_templates`
  ADD CONSTRAINT `masters_email_templates_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_email_templates_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_functional_areas`
--
ALTER TABLE `masters_functional_areas`
  ADD CONSTRAINT `masters_functional_areas_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_functional_areas_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_industries`
--
ALTER TABLE `masters_industries`
  ADD CONSTRAINT `masters_industries_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_industries_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_institutes`
--
ALTER TABLE `masters_institutes`
  ADD CONSTRAINT `masters_institutes_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_institutes_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_job_roles`
--
ALTER TABLE `masters_job_roles`
  ADD CONSTRAINT `masters_job_roles_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_job_roles_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_keywords`
--
ALTER TABLE `masters_keywords`
  ADD CONSTRAINT `masters_keywords_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_keywords_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `masters_specializations`
--
ALTER TABLE `masters_specializations`
  ADD CONSTRAINT `masters_specializations_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_specializations_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_specializations_ibfk_3` FOREIGN KEY (`degree_id`) REFERENCES `masters_degrees` (`id`);

--
-- Constraints for table `masters_trainings`
--
ALTER TABLE `masters_trainings`
  ADD CONSTRAINT `masters_trainings_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `masters_trainings_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`);

--
-- Constraints for table `organizations`
--
ALTER TABLE `organizations`
  ADD CONSTRAINT `organizations_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `organizations_ibfk_2` FOREIGN KEY (`modified_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `organizations_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `organizations_settings`
--
ALTER TABLE `organizations_settings`
  ADD CONSTRAINT `organizations_settings_ibfk_1` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL;

--
-- Constraints for table `users_candidate`
--
ALTER TABLE `users_candidate`
  ADD CONSTRAINT `users_candidate_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_candidate_ibfk_2` FOREIGN KEY (`industry_id`) REFERENCES `masters_industries` (`id`),
  ADD CONSTRAINT `users_candidate_ibfk_3` FOREIGN KEY (`functional_area_id`) REFERENCES `masters_functional_areas` (`id`);

--
-- Constraints for table `users_certifications`
--
ALTER TABLE `users_certifications`
  ADD CONSTRAINT `users_certifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_certifications_ibfk_2` FOREIGN KEY (`training_id`) REFERENCES `masters_trainings` (`id`);

--
-- Constraints for table `users_educations`
--
ALTER TABLE `users_educations`
  ADD CONSTRAINT `users_educations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_educations_ibfk_2` FOREIGN KEY (`degree_id`) REFERENCES `masters_degrees` (`id`);

--
-- Constraints for table `users_jobs`
--
ALTER TABLE `users_jobs`
  ADD CONSTRAINT `users_jobs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_jobs_ibfk_2` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users_job_details`
--
ALTER TABLE `users_job_details`
  ADD CONSTRAINT `users_job_details_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users_languages`
--
ALTER TABLE `users_languages`
  ADD CONSTRAINT `users_languages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users_organizations`
--
ALTER TABLE `users_organizations`
  ADD CONSTRAINT `users_organizations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_organizations_ibfk_2` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  ADD CONSTRAINT `users_organizations_ibfk_3` FOREIGN KEY (`client_vertical_id`) REFERENCES `clients_verticals` (`id`),
  ADD CONSTRAINT `users_organizations_ibfk_5` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE SET NULL,
  ADD CONSTRAINT `users_organizations_ibfk_6` FOREIGN KEY (`organization_id`) REFERENCES `organizations` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_organizations_ibfk_7` FOREIGN KEY (`client_vertical_location_id`) REFERENCES `clients_verticals_locations` (`id`),
  ADD CONSTRAINT `users_organizations_ibfk_8` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`);

--
-- Constraints for table `users_professions`
--
ALTER TABLE `users_professions`
  ADD CONSTRAINT `users_professions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `users_professions_ibfk_3` FOREIGN KEY (`designation_id`) REFERENCES `masters_designations` (`id`);

--
-- Constraints for table `users_reporting`
--
ALTER TABLE `users_reporting`
  ADD CONSTRAINT `users_reporting_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `users_reporting_ibfk_2` FOREIGN KEY (`parent_user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users_resumes`
--
ALTER TABLE `users_resumes`
  ADD CONSTRAINT `users_resumes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `users_skills`
--
ALTER TABLE `users_skills`
  ADD CONSTRAINT `users_skills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
