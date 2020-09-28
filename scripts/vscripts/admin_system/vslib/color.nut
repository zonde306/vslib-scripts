
class ::VSLib.Color
{
	constructor(_r = -1, _g = -1, _b = -1, _a = 255)
	{
		if(_r == -1)
		{
			r = 255;
			g = 255;
			b = 255;
			a = 255;
		}
		else if(_g == -1 && _b == -1)
		{
			r = _r & 0xFF;
			g = (_r & 0xFF00) >> 8;
			b = (_r & 0xFF0000) >> 16;
			a = (_r & 0xFF000000) >> 24;
		}
		else
		{
			r = _r;
			g = _g;
			b = _b;
			a = _a;
		}
	}
	
	function _cmp(other)
	{
		if("r" in other && "g" in other && "b" in other && "a" in other)
		{
			local oc = (other.r) | (other.g << 8) | (other.b << 16) | (other.a << 24);
			local tc = (r) | (g << 8) | (b << 16) | (a << 24);
			
			if(oc == tc)
				return 0;
			else if(tc > oc)
				return 1;
			else
				return -1;
		}
	}
	
	function _typeof()
	{
		return "VSLIB_COLOR";
	}
	
	r = 255;
	g = 255;
	g = 255;
	a = 255;
}

function VSLib::Color::tointeger()
{
	return (r & 0xFF) | ((g & 0xFF) << 8) | ((b & 0xFF) << 16) | ((a & 0xFF) << 24);
}

function VSLib::Color::tostring()
{
	return (r + " " + g + " " + b);
}
