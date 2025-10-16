const mongoose=require('mongoose');
const DB_NAME = "CivicResponses"; 

const connectDB=async ()=>{
    try{
        const connectionInstance=await mongoose.connect(`${process.env.DB_URI}/${DB_NAME}`);
        console.log(`Mongo DB Connected!! \n Host : ${connectionInstance.connection.host}`);
        console.log(`DB Name : ${connectionInstance.connection.name}`);

    }catch(error){
        console.log("Connection Error :",error);
        process.exit(1);
    }
}

module.exports=connectDB;