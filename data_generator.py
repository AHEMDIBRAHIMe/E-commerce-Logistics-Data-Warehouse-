import csv
import random
import uuid
from datetime import datetime, timedelta

# Install faker if you haven't: pip install faker
try:
    from faker import Faker
except ImportError:
    print("Please install faker: pip install faker")
    exit(1)

fake = Faker('ar_SA') # Setting to Arabic for realistic MENA data

# Config
NUM_CUSTOMERS = 1000
NUM_COURIERS = 100
NUM_ORDERS = 10000

# Regions
REGIONS = ['Riyadh', 'Jeddah', 'Dammam', 'Mecca', 'Medina']

def generate_customers():
    customers = []
    for _ in range(NUM_CUSTOMERS):
        customers.append({
            'customer_id': str(uuid.uuid4()),
            'name': fake.name(),
            'phone': fake.phone_number(),
            'region': random.choice(REGIONS),
            'registration_date': fake.date_between(start_date='-2y', end_date='today').isoformat()
        })
    return customers

def generate_couriers():
    couriers = []
    for _ in range(NUM_COURIERS):
        couriers.append({
            'courier_id': str(uuid.uuid4()),
            'name': fake.name(),
            'vehicle_type': random.choice(['Motorcycle', 'Car', 'Van']),
            'rating': round(random.uniform(3.5, 5.0), 2)
        })
    return couriers

def generate_orders(customers, couriers):
    orders = []
    deliveries = []
    
    for _ in range(NUM_ORDERS):
        customer = random.choice(customers)
        courier = random.choice(couriers)
        
        order_id = str(uuid.uuid4())
        
        # Order timeline
        created_at = fake.date_time_between(start_date='-1y', end_date='now')
        preparation_time = timedelta(minutes=random.randint(10, 45))
        prepared_at = created_at + preparation_time
        
        # Delivery timeline
        picking_time = timedelta(minutes=random.randint(5, 20))
        picked_up_at = prepared_at + picking_time
        
        # Distance/Traffic simulation
        transit_time = timedelta(minutes=random.randint(15, 120))
        delivered_at = picked_up_at + transit_time
        
        # Status
        status = random.choices(
            ['Delivered', 'Cancelled', 'Failed_Delivery'],
            weights=[0.85, 0.10, 0.05]
        )[0]
        
        if status != 'Delivered':
            delivered_at = None
        
        order_amount = round(random.uniform(50, 1500), 2)
        
        # Order Record
        orders.append({
            'order_id': order_id,
            'customer_id': customer['customer_id'],
            'status': status,
            'order_amount': order_amount,
            'created_at': created_at.isoformat(),
            'prepared_at': prepared_at.isoformat()
        })
        
        # Delivery Record
        rating = None
        if status == 'Delivered':
            # Late deliveries get worse ratings
            total_time = (delivered_at - created_at).total_seconds() / 60
            if total_time > 90:
                rating = random.randint(1, 4)
            else:
                rating = random.randint(3, 5)

        deliveries.append({
            'delivery_id': str(uuid.uuid4()),
            'order_id': order_id,
            'courier_id': courier['courier_id'],
            'picked_up_at': picked_up_at.isoformat() if status != 'Cancelled' else None,
            'delivered_at': delivered_at.isoformat() if delivered_at else None,
            'delivery_fee': round(random.uniform(10, 50), 2),
            'customer_rating': rating
        })

    return orders, deliveries

def save_to_csv(filename, data, fieldnames):
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)
    print(f"[{filename}] generated with {len(data)} records.")

if __name__ == "__main__":
    print("Generating Mock Data...")
    
    customers = generate_customers()
    save_to_csv('users.csv', customers, customers[0].keys())
    
    couriers = generate_couriers()
    save_to_csv('couriers.csv', couriers, couriers[0].keys())
    
    orders, deliveries = generate_orders(customers, couriers)
    save_to_csv('orders.csv', orders, orders[0].keys())
    save_to_csv('deliveries.csv', deliveries, deliveries[0].keys())
    
    print("Done! Data is ready for S3/GCS upload.")
