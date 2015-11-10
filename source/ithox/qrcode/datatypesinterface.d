module ithox.qrcode.datatypesinterface;

alias StringString = string[string];

/**
* Simple Laravel QrCode Generator
* @author donglei
*
*/
interface DataTypesInterface{

	public void create(StringString args);
	public string toString();
}

class PhoneNumber : DataTypesInterface{
	private{
		const string prefix="tel:";
		string phoneNumber;
	}

	public void create(StringString args)
	{
		this.phoneNumber = args["phone"];
	}

	
	public override string toString()
	{
		return prefix ~ phoneNumber;
	}

}

//TODO
class Email : DataTypesInterface{
	private{
		const string prefix="mailto:";
	}
	public void create(StringString args){}
	public override string toString(){
		return prefix;
	}
}


class Geo  : DataTypesInterface{

	private{
		const string prefix="geo:";
		const string separator = ",";
		string latitude, longitude;
	}
	public void create(StringString args){
		latitude = args.get("latitude", "");
		longitude = args.get("longitude", "");
	}
	public override string toString(){
		return prefix ~ latitude ~ separator ~longitude;
	}
}

class SMS : DataTypesInterface{

	private{
		string phoneNumber, message;
	}
	public void create(StringString args){
		phoneNumber = args.get("phone", "");
		message = args.get("message", "");
	}

	public override string toString(){
		auto sms = "sms:" ~ phoneNumber;
		if(message.length != 0)
		{
			sms ~= ":" ~ message;
		}
		return sms;

	}
}
