db = db.getSiblingDB("airflow");
db.getCollection("_fastop_pipelines").deleteMany({"_id": { "$regex": /^hicp\./i } });
db.getCollection("_fastop_pipelines").insertMany([
    {
        "_id": "hicp.get_index_periods",
        "pipeline": [
            { "$limit" : 1 },
            { "$unwind": "$ts" },
            { "$group": {"_id": "$ts._id"} },
            { "$sort": { "_id": 1} },
        ]
    },
    {
        "_id": "hicp.get_index_data",
        "pipeline": [
            {
                "$match": {
                    "$and": [
                        { "dimensions.geo": "p_country_id" },
                        { "dimensions.unit": { "$in": "p_units" } },
                        { "dimensions.coicop": { "$in": "p_coicops" } }
                    ]
                }
            },
            { "$unwind": "$ts" },
            {
                "$group": {
                    "_id": "$_id",
                    "values": { "$push": "$ts.observations.value" },
                    "timestamp": { "$push": "$ts._id" }
                }
            }
        ]
    },
    {
        "_id": "hicp.get_weights_data",
        "pipeline": [
            {
                "$match": {
                    "$and": [
                        { "dimensions.geo": "p_country_id" },
                        { "dimensions.coicop": { "$in": "p_coicops" } }
                    ]
                }
            },
            { "$unwind": "$ts" },
            {
                "$group": {
                    "_id": "$_id",
                    "values": { "$push": "$ts.observations.value" },
                    "timestamp": { "$push": "$ts._id" }
                }
            }
        ]
    }
]);
