set CARS;   # Two types of cars, represent the number of each cars
set DEPARTURE; # All the depature point, where the product is produced
set DESTINATION; # The destination, where the product will be sold
set PRODUCTS; # The disfferent kinds of products

param distance {DEPARTURE, DESTINATION}; # The distance between depature and destination point
param cost {CARS}; # The cost for each type of car per mile
param rent {CARS}; # The rent fee of each car per week
param capacity {CARS}; # How many products can each type of car carrry
param supply {DEPARTURE, PRODUCTS}; # The total supply for each kind of product in the departure
param demand {DESTINATION, PRODUCTS}; # The total demand for each kind of product at destination
param revenue{PRODUCTS}; # The revenue for single product
param carbon_emission; # 
 
var amount {CARS} >= 0; # How many of each car the company need
var trans {DEPARTURE, DESTINATION, CARS, PRODUCTS} >= 0, integer; # How many cars should be assigned to each road, and what kind of product should they carry

subject to CARS_AMOUNT {k in CARS}: # The amount of rented cars should equal to the amount of cars been assigned to roads
	sum {i in DEPARTURE, j in DESTINATION, r in PRODUCTS} trans[i, j, k, r] = amount[k]; 
subject to PRODUCT_SUPPLY {i in DEPARTURE, r in PRODUCTS}: # The total supply of each product should equal to the product carried by different cars
	sum {j in DESTINATION, k in CARS} trans[i, j, k, r] <= supply[i , r];
subject to PRODUCT_DEMAND {j in DESTINATION, r in PRODUCTS}: # The total demand of product should equal to the demand at destination	
	sum {i in DEPARTURE, k in CARS} trans[i, j, k, r] >= demand[j, r];
	
maximize profit: # The final profit, equals to the revenue from all products, substract the cost on road, and the rent fee
	sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * capacity[k] * revenue[r] - sum {i in DEPARTURE, j in DESTINATION, k in CARS, r in PRODUCTS} trans[i, j, k, r] * cost[k] * distance[i, j] - sum {k in CARS} rent[k] * amount[k];
	
	