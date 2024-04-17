CREATE TABLE `ebowned_vehicles` (
  `owner` varchar(46) DEFAULT NULL,
  `label` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `vehtype` varchar(50) NOT NULL,
  `vehicleprops` varchar(2550) DEFAULT NULL,
  `numberplate` varchar(50) NOT NULL,
  `area` varchar(50) NOT NULL,
  `leased` INT NOT NULL,
  `impounded` INT NOT NULL,
  `parked` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
