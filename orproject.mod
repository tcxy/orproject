set CARS;   # Two types of cars, represent the number of each cars
set DEPARTURE; # All the depature point, where the product is produced
set DESTINATION; # The destination, where the product will be sold
set PRODUCTS; # The disfferent kinds of products
param n;
param m;
set I := 1..n;
set K := 1..m;
set SUPPLIER; # five suppliers of the raw material
set SIZE; # three sizes of the raw material


param p{i in I, k in K}, >=0;
param d{i in I}, >=0;
param bigM := max{i in I}(d[i]);

param distance {DEPARTURE, DESTINATION}; # The distance between depature and destination point
param cost {CARS}; # The cost for each type of car per mile
param rent {CARS}; # The rent fee of each car per week
param capacity {CARS}; # How many products can each type of car carrry
param supply {DEPARTURE, PRODUCTS}; # The total supply for each kind of product in the departure
param demand {DESTINATION, PRODUCTS}; # The total demand for each kind of product at destination
param revenue{PRODUCTS}; # The revenue for single product
param car_limit{CARS}; 

param travel_time {DEPARTURE, DESTINATION, CARS};

param s_cost {SUPPLIER}; # The cost of each order from suppliers
param s_limit {SUPPLIER}; # The supply limits of the suppliers
param contain {SUPPLIER, SIZE}; # Number of different sizes of raw material in one order of each supplier
param component {PRODUCTS, SIZE}; # Number of different sizes of raw material in products

param loading_workers {DEPARTURE, PRODUCTS}; # The wages of workers in the departure for each car, with different products have different wages
param unloading_workers {DESTINATION, PRODUCTS}; # The wages of workers in the destination for each car, with different products have different wages
param workers_drivers {DEPARTURE, DESTINATION}; # The wages of drivers from departure to destination
#param driver_salary >= 0 default 20;  

var total_trans {DEPARTURE, DESTINATION, CARS, PRODUCTS} >= 0, integer; # How many cars should be assigned to each road, and what kind of product should they carry
var car_amount {DEPARTURE, DESTINATION, CARS, PRODUCTS} >= 0, integer;
var amount {CARS} >= 0, integer;
var t{i in I, k in K}, >=0;
var y{i in I, j in I, k in K}, binary;
var eta, >=0;
var order {SUPPLIER} >= 0, integer; # How many orders should be ordered in each supplier
var driver_salary >= 0, integer;
var drivers >= 0, integer;

# The travel time constraint
subject to AMOUNT {k in CARS}:
	amount[k] = sum {i in DEPARTURE, j in DESTINATION, r in PRODUCTS} car_amount[i, j, k, r];
subject to CAR_LIMIT {k in CARS}:
	sum {i in DEPARTURE, j in DESTINATION, r in PRODUCTS} car_amount[i, j, k, r] <= car_limit[k];
subject to TRANS_TIME {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS}:
	car_amount[i, j, k, r] * (20 / travel_time[i, j, k]) - total_trans[i, j, k, r] >= 0;
subject to PRODUCT_SUPPLY {i in DEPARTURE, r in PRODUCTS}: # The total supply of each product should equal to the product carried by different cars
	sum {j in DESTINATION, k in CARS} total_trans[i, j, k, r]* capacity[k] <= supply[i , r];
subject to PRODUCT_DEMAND {j in DESTINATION, r in PRODUCTS}: # The total demand of product should equal to the demand at destination	
	sum {i in DEPARTURE, k in CARS} total_trans[i, j, k, r]* capacity[k] >= demand[j, r];


subject to raw_materal_limit {i in SUPPLIER}: 
 sum {j in SIZE} (contain[i,j]*order[i]) <= s_limit[i]; # supplier limit constraint for each supplier
subject to raw_materal_demand {j in SIZE}: # meet the production requirements of each size of material
 sum {i in SUPPLIER} (contain[i,j]*order[i]) >= sum {r in PRODUCTS, k in DEPARTURE} (component[r,j]*supply[k,r]); # demand constraint

subject to eta_max{i in I}:
eta >= t[i,m] + p[i,m];
subject to deadline{i in I}:
t[i,m] + p[i,m] <= d[i];
subject to disjunction_1{i in I, j in I, k in K: i<j}:
t[i,k] + p[i,k] <= t[j,k] + bigM*(1-y[i,j,k]);
subject to disjunction_2{i in I, j in I, k in K: i<j}:
t[j,k] + p[j,k] <= t[i,k] + bigM*y[i,j,k];
subject to sequence{i in I, k in (K diff {m})}:
t[i,k] + p[i,k] <= t[i,k+1];


# minimize Raw_material_cost: sum {i in SUPPLIER} (s_cost[i] * order[i]);
	
maximize profit: # The final profit, equals to the revenue from all products, substract the cost on road, and the rent fee
    sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} total_trans[i, j, k, r] * capacity[k] * revenue[r] 
    -sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} total_trans[i, j, k, r] * cost[k] * distance[i, j] 
    - sum {k in CARS} rent[k] * sum {i in DEPARTURE, j in DESTINATION, r in PRODUCTS} car_amount[i, j, k, r]
    - sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} total_trans[i, j, k, r] * loading_workers[i,r]
    - sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} total_trans[i, j, k, r] * unloading_workers[j,r] 
    - sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} total_trans[i, j, k, r] * workers_drivers[i,j]
    - sum {i in SUPPLIER} (s_cost[i] * order[i])
    - 10000*eta 
    - 6000*eta;


    
    
    
    
    
    
    
    
    
    
    
    
    
	
