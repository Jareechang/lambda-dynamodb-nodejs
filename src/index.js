const AWS = require('aws-sdk');
const ddb = new AWS.DynamoDB({
    apiVersion: '2012-08-10'
})

// @ts-ignore
const listTables = () => {
    const params = {
        TableName: "Book"
    };
    return new Promise((resolve, reject) => {
        ddb.describeTable(params, (err, data) => {
            if (err) return reject(err);
            resolve(data);
        });
    });
}

exports.handler = async function(event, context) {
    console.log("EVENT: \n" + JSON.stringify(event, null, 2))

    const tables = await listTables();

    console.log('Tables', tables);
}
