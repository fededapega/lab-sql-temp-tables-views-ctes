USE sakila;

#customer_rental_info = CUSTOMER(cid, name, email)  RENTAL(count of rentals)
#First, create a view that summarizes rental information for each customer. 
#The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_info AS
								SELECT c.customer_id, CONCAT(first_name," ",last_name) as full_name, email, total_rentals
								FROM customer c
								JOIN(
										SELECT customer_id, COUNT(rental_id) as total_rentals 
										FROM rental
										GROUP BY customer_id) cu
								ON c.customer_id = cu.customer_id
								ORDER BY total_rentals DESC;


#Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
#The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.


CREATE TEMPORARY TABLE Revenue_per_Customer (
												SELECT cri.customer_id, total_paid
												FROM customer_rental_info cri
												JOIN(
																			SELECT customer_id, SUM(amount) AS total_paid
																			FROM payment
																			GROUP BY customer_id) pri
												ON cri.customer_id = pri.customer_id
												ORDER BY total_paid DESC);


#Step 3: Create a CTE and the Customer Summary Report
#Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
#The CTE should include the customer's name, email address, rental count, and total amount paid.




WITH customer_report AS(
						SELECT *
						FROM customer_rental_info cri
						JOIN Revenue_per_Customer rpc
						USING (customer_id))
                        
SELECT full_name, email, total_rentals, total_paid,
					total_paid / total_rentals OVER(PARTITION BY average_payment_per_rental) as average_per_rental
FROM customer_report;


# i don't know what's going on here :(








