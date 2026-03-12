# E-commerce & Logistics Data Warehouse
![Project Banner](./banner.png)

هذا المشروع يبرز كيفية تصميم وبناء مستودع بيانات كامل (Data Warehouse) لتطبيق تجارة إلكترونية شامل (Super-app)، مع التركيز على العمليات اللوجستية، إدارة المبيعات، وتحليل أداء التوصيل.

## الفكرة المعمارية (Architecture)

```mermaid
graph TD
    %% Define Styles
    classDef generator fill:#f9f,stroke:#333,stroke-width:2px;
    classDef storage fill:#ff9,stroke:#333,stroke-width:2px;
    classDef warehouse fill:#9cf,stroke:#333,stroke-width:2px;
    classDef dbt fill:#f96,stroke:#333,stroke-width:2px;
    classDef bi fill:#ccf,stroke:#333,stroke-width:2px;

    %% Nodes
    A[Python Faker Script<br/>Mock Data Generation]:::generator
    
    subgraph Data Lake
        B[(Amazon S3 / GCS<br/>Raw CSV Files)]:::storage
    end
    
    subgraph Data Warehouse
        C[(Snowflake / Redshift<br/>Staging Tables)]:::warehouse
        D{{dbt<br/>Data Transformation}}:::dbt
        E[(Marts / Fact & Dim Tables)]:::warehouse
    end
    
    F[BI Tools: Tableau / PowerBI<br/>SQL Analytics]:::bi

    %% Edges
    A -- Generates Users, Orders,<br/>Couriers, Deliveries --> B
    B -- Copy / Load Data --> C
    C -- Raw Data --> D
    D -- Cleans, Calculates SLAs,<br/>Builds Models --> E
    E -- Analyzes Delivery Times<br/>& Peak Hours --> F
```

1. **Mock Data Generation**: سكريبت بايثون `data_generator.py` يقوم بتوليد مئات الآلاف من السجلات الوهمية للعملاء، المناديب، الطلبات، وعمليات التوصيل.
2. **Data Lake (S3 / GCS)**: تُحفظ البيانات الخام (Raw CSVs) الناتجة من السكريبت في Amazon S3 أو Google Cloud Storage.
3. **Data Warehouse (Snowflake / Redshift)**: يتم تحميل البيانات من S3 إلى جداول مؤقتة (Staging).
4. **Data Modeling (dbt)**: تُستخدم dbt لبناء جداول الحقائق والأبعاد (Fact & Dimension Tables)، وتنظيف البيانات وحساب المقاييس اللوجستية (تحويل Staging إلى Marts).
5. **Analytics (SQL)**: كتابة استعلامات معقدة للإجابة على الأسئلة التجارية الجوهرية.

## محتويات المشروع
- `data_generator.py`: مولد البيانات الوهمية. يعتمد على مكتبة `faker`.
- `dbt_models/`: مجلد يحتوي على نماذج dbt (مثل `fct_deliveries` و `fct_orders`) لتحويل البيانات وحساب الـ SLAs وأوقات الانتظار.
- `sql_queries/analytical_queries.sql`: يحتوي على 4 استعلامات رئيسية تغطي:
  1. أكثر المناطق تأخراً في التوصيل وتحليل الـ SLA.
  2. تحليل أوقات الذروة للحضور والانصراف (Peak Hours) وتأثيرها.
  3. تقييم أداء المناديب بناءً على نسب النجاح وتقييم العملاء.
  4. تحديد الاختناقات اللوجستية (Bottlenecks) سواء من أوقات التحضير أو الانتظار.

## كيفية الاستخدام (How to Use)
### 1. توليد البيانات
```bash
pip install faker
python data_generator.py
```
سينتج عن هذا 4 ملفات: `users.csv`, `couriers.csv`, `orders.csv`, `deliveries.csv`.

### 2. تجهيز Data Warehouse
- قم بإنشاء مستودع في Snowflake أو Redshift.
- قم بعمل Bulk Insert للملفات الأربعة في جداول الـ Staging.

### 3. تشغيل dbt
داخل المجلد الذي سيحتوي على إعدادات dbt، قم بتشغيل:
```bash
dbt run
dbt test
```
سيقوم ذلك ببناء الجداول النهائية المجهزة للتحليل.

### 4. التحليل
استخدم الاستعلامات الموجودة في `sql_queries/analytical_queries.sql` في أداة الـ BI الخاصة بك (مثل Tableau / PowerBI / Metabase) أو عبر منصة الـ Database مباشرة.
