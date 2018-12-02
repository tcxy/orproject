set CARS;   # Two types of cars, represent the number of each cars
set DEPARTURE; # All the depature point, where the product is produced
set DESTINATION; # The destination, where the product will be sold
set PRODUCTS; # The disfferent kinds of products
set SUPPLIER; # five suppliers of the raw material
set SIZE; # three sizes of the raw material

param distance {DEPARTURE, DESTINATION}; # The distance between depature and destination point
param cost {CARS}; # The cost for each type of car per mile
param rent {CARS}; # The rent fee of each car per week
param capacity {CARS}; # How many products can each type of car carrry
param supply {DEPARTURE, PRODUCTS}; # The total supply for each kind of product in the departure
param demand {DESTINATION, PRODUCTS}; # The total demand for each kind of product at destination
param revenue{PRODUCTS}; # The revenue for single product
param carbon_emission; # 
param workers_supply {DEPARTURE, PRODUCTS}; # The wages of workers in the departure for each car, with different products have different wages
param workers_demand {DESTINATION, PRODUCTS}; # The wages of workers in the destination for each car, with different products have different wages
param s_cost {SUPPLIER}; # The cost of each order from suppliers
param s_limit {SUPPLIER}; # The supply limits of the suppliers
param contain {SUPPLIER, SIZE}; # Number of different sizes of raw material in one order of each supplier
param component {PRODUCTS, SIZE}; # Number of different sizes of raw material in products
# param time_for_car {DEPATURE, DESTINATION, CARS};




var amount {CARS} >= 0; # How many of each car the company need
var trans {DEPARTURE, DESTINATION, CARS, PRODUCTS} >= 0, integer; # How many cars should be assigned to each road, and what kind of product should they carry
var order {SUPPLIER} >= 0, integer; # How many orders should be ordered in each supplier

# subject to TIME_CONSTRAINT {k in CARS}:
#	sum {i in DEPATURE, j in DESTINATION, r in PRODUCTS} trans[i, j, k, r] * time_for_car[i, j, k] * 2 <= 40;
# The working cost, < 8 hours 20, portion > 8 hours 20 * 1.5
subject to CARS_AMOUNT {k in CARS}: # The amount of rented cars should equal to the amount of cars been assigned to roads
	sum {i in DEPARTURE, j in DESTINATION, r in PRODUCTS} trans[i, j, k, r] = amount[k]; 
subject to PRODUCT_SUPPLY {i in DEPARTURE, r in PRODUCTS}: # The total supply of each product should equal to the product carried by different cars
	sum {j in DESTINATION, k in CARS} trans[i, j, k, r] * capacity[k] <= supply[i , r];
subject to PRODUCT_DEMAND {j in DESTINATION, r in PRODUCTS}: # The total demand of product should equal to the demand at destination	
	sum {i in DEPARTURE, k in CARS} trans[i, j, k, r] * capacity[k] >= demand[j, r];
subject to raw_materal_limit {i in SUPPLIER}: 
	sum {j in SIZE} (contain[i,j]*order[i]) <= s_limit[i]; # supplier limit constraint for each supplier
subject to raw_materal_demand {i in SIZE}: 
	sum {j in SUPPLIER} (contain[j,i]*order[j]) >= sum {p in PRODUCTS, d in DESTINATION} (component[p,i]*demand[d,p]);
# The working cost for drivers
# One variable as binary to calcualte if one day the working time exceeds 8 hours	
maximize profit: # The final profit, equals to the revenue from all products, substract the cost on road, and the rent fee
	sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * capacity[k] * revenue[r] - sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * cost[k] * distance[i, j] - sum {k in CARS} rent[k] * amount[k]- sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * workers_supply[i,r]- sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * workers_demand[j,r] - sum {k in CARS} 3000 * amount[k] - sum {i in SUPPLIER} (s_cost[i] * order[i]);
minimize Raw_material_cost: sum {i in SUPPLIER} (s_cost[i] * order[i]);
	
