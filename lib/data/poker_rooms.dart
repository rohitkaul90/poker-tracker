class PokerRoom {
  final String name;
  final String region;
  final String city;
  final String currency;
  final String country;
  final bool isOnline;

  const PokerRoom({
    required this.name,
    required this.region,
    required this.city,
    required this.currency,
    required this.country,
    this.isOnline = false,
  });

  String get storageKey => isOnline ? 'Online – $name' : name;
  String get subtitle => isOnline ? 'Online' : city;
}

bool isOnlineSession(String? location) {
  if (location == null || location.isEmpty) return false;
  // Sessions logged via picker use "Online – Name" prefix
  if (location.startsWith('Online –') || location.startsWith('Online -')) {
    return true;
  }
  // Imported sessions may use just the platform name — check against known online rooms
  final loc = location.toLowerCase();
  return kPokerRooms.any(
    (r) => r.isOnline && r.name.toLowerCase() == loc,
  );
}

String? countryFromLocation(String? locationKey) {
  if (locationKey == null || locationKey.isEmpty) return null;
  return kPokerRooms.where((r) => r.storageKey == locationKey).firstOrNull?.country;
}

const kPokerRooms = <PokerRoom>[
  // ── Online ──────────────────────────────────────────────────────────────────
  PokerRoom(name: 'PokerStars', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'GGPoker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'partypoker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: '888poker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Americas Cardroom', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'WSOP.com', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'BetOnline', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Bovada Poker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'WPN (Winning Poker Network)', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'PokerKing', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Ignition Casino', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Natural8', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'iPoker Network', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'PokerOK', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Global Poker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'ClubGG', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Poker Bros', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'PokerBros', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'IDNPoker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'KKPoker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'BetMGM Poker', region: 'Online', city: 'Online', currency: 'USD', country: 'Online', isOnline: true),
  PokerRoom(name: 'Run It Once Poker', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'Unibet Poker', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'Winamax', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'PMU Poker', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'Bwin Poker', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'bwin', region: 'Online', city: 'Online', currency: 'EUR', country: 'Online', isOnline: true),
  PokerRoom(name: 'bet365 Poker', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'bet365', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'Betfair Poker', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'Betfair', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'William Hill Poker', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'Ladbrokes Poker', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  PokerRoom(name: 'Ladbrokes', region: 'Online', city: 'Online', currency: 'GBP', country: 'United Kingdom', isOnline: true),
  // ── Online – India ───────────────────────────────────────────────────────────
  PokerRoom(name: 'PokerBaazi', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: 'Adda52', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: 'Spartan Poker', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: '9stacks', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: 'PokerHigh', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: 'GetMega', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),
  PokerRoom(name: 'Pocket52', region: 'Online – India', city: 'Online', currency: 'INR', country: 'India', isOnline: true),

  // ── Canada – Ontario ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Woodbine Casino', region: 'Canada – Ontario', city: 'Toronto, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Pickering Casino Resort', region: 'Canada – Ontario', city: 'Pickering, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elements Casino Ajax', region: 'Canada – Ontario', city: 'Ajax, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elements Casino Flamboro', region: 'Canada – Ontario', city: 'Dundas, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elements Casino Mohawk', region: 'Canada – Ontario', city: 'Campbellville, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elements Casino Grand River', region: 'Canada – Ontario', city: 'Elora, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elements Casino Brantford', region: 'Canada – Ontario', city: 'Brantford, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Casino Rama Resort', region: 'Canada – Ontario', city: 'Orillia, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Great Blue Heron Casino', region: 'Canada – Ontario', city: 'Port Perry, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Fallsview Casino Resort', region: 'Canada – Ontario', city: 'Niagara Falls, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Casino Niagara', region: 'Canada – Ontario', city: 'Niagara Falls, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Shorelines Casino Thousand Islands', region: 'Canada – Ontario', city: 'Gananoque, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Shorelines Casino Belleville', region: 'Canada – Ontario', city: 'Belleville, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Shorelines Casino Peterborough', region: 'Canada – Ontario', city: 'Peterborough, ON', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'OLG Casino Ottawa', region: 'Canada – Ontario', city: 'Ottawa, ON', currency: 'CAD', country: 'Canada'),

  // ── Canada – Quebec ──────────────────────────────────────────────────────────
  PokerRoom(name: 'Playground Poker Club', region: 'Canada – Quebec', city: 'Kahnawake, QC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Casino de Montréal', region: 'Canada – Quebec', city: 'Montreal, QC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Casino Lac-Leamy', region: 'Canada – Quebec', city: 'Gatineau, QC', currency: 'CAD', country: 'Canada'),

  // ── Canada – Alberta ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Grey Eagle Resort & Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Elbow River Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Cash Casino Calgary', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'River Cree Resort & Casino', region: 'Canada – Alberta', city: 'Edmonton, AB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Palace Casino', region: 'Canada – Alberta', city: 'Edmonton, AB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Deerfoot Inn & Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD', country: 'Canada'),

  // ── Canada – British Columbia ────────────────────────────────────────────────
  PokerRoom(name: 'Starlight Casino', region: 'Canada – British Columbia', city: 'New Westminster, BC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Parq Vancouver', region: 'Canada – British Columbia', city: 'Vancouver, BC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Hard Rock Casino Vancouver', region: 'Canada – British Columbia', city: 'Coquitlam, BC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'River Rock Casino Resort', region: 'Canada – British Columbia', city: 'Richmond, BC', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Chances Casino', region: 'Canada – British Columbia', city: 'Various, BC', currency: 'CAD', country: 'Canada'),

  // ── Canada – Manitoba ────────────────────────────────────────────────────────
  PokerRoom(name: 'Club Regent Casino', region: 'Canada – Manitoba', city: 'Winnipeg, MB', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'McPhillips Station Casino', region: 'Canada – Manitoba', city: 'Winnipeg, MB', currency: 'CAD', country: 'Canada'),

  // ── Canada – Saskatchewan ────────────────────────────────────────────────────
  PokerRoom(name: 'Casino Regina', region: 'Canada – Saskatchewan', city: 'Regina, SK', currency: 'CAD', country: 'Canada'),
  PokerRoom(name: 'Casino Moose Jaw', region: 'Canada – Saskatchewan', city: 'Moose Jaw, SK', currency: 'CAD', country: 'Canada'),

  // ── USA – Las Vegas ──────────────────────────────────────────────────────────
  PokerRoom(name: 'Bellagio', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Wynn Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'ARIA Resort & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'The Venetian Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Caesars Palace', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Horseshoe Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'MGM Grand', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Resorts World Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Red Rock Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Paris Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Planet Hollywood Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'South Point Hotel & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'The Orleans Hotel & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Golden Nugget Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Binion\'s Gambling Hall', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Treasure Island', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Palms Casino Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD', country: 'USA'),

  // ── USA – Los Angeles ────────────────────────────────────────────────────────
  PokerRoom(name: 'Commerce Casino', region: 'USA – Los Angeles', city: 'Commerce, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'The Bicycle Casino', region: 'USA – Los Angeles', city: 'Bell Gardens, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Hustler Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Hollywood Park Casino', region: 'USA – Los Angeles', city: 'Inglewood, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Larry Flynt\'s Lucky Lady Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Normandie Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Hawaiian Gardens Casino', region: 'USA – Los Angeles', city: 'Hawaiian Gardens, CA', currency: 'USD', country: 'USA'),

  // ── USA – Northern California ────────────────────────────────────────────────
  PokerRoom(name: 'Bay 101 Casino', region: 'USA – Northern California', city: 'San Jose, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Stones Gambling Hall', region: 'USA – Northern California', city: 'Sacramento, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Lucky Chances Casino', region: 'USA – Northern California', city: 'Colma, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'The Oaks Card Club', region: 'USA – Northern California', city: 'Emeryville, CA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Cache Creek Casino Resort', region: 'USA – Northern California', city: 'Brooks, CA', currency: 'USD', country: 'USA'),

  // ── USA – Pacific Northwest ──────────────────────────────────────────────────
  PokerRoom(name: 'Snoqualmie Casino', region: 'USA – Pacific Northwest', city: 'Snoqualmie, WA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Muckleshoot Casino', region: 'USA – Pacific Northwest', city: 'Auburn, WA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Tulalip Resort Casino', region: 'USA – Pacific Northwest', city: 'Tulalip, WA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Ilani Casino Resort', region: 'USA – Pacific Northwest', city: 'Ridgefield, WA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Chinook Winds Casino Resort', region: 'USA – Pacific Northwest', city: 'Lincoln City, OR', currency: 'USD', country: 'USA'),

  // ── USA – Arizona ────────────────────────────────────────────────────────────
  PokerRoom(name: 'Talking Stick Resort', region: 'USA – Arizona', city: 'Scottsdale, AZ', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Casino Arizona at Salt River', region: 'USA – Arizona', city: 'Scottsdale, AZ', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Harrah\'s Ak-Chin Casino', region: 'USA – Arizona', city: 'Maricopa, AZ', currency: 'USD', country: 'USA'),

  // ── USA – East Coast ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Borgata Hotel Casino', region: 'USA – East Coast', city: 'Atlantic City, NJ', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Harrah\'s Philadelphia', region: 'USA – East Coast', city: 'Chester, PA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Rivers Casino Philadelphia', region: 'USA – East Coast', city: 'Philadelphia, PA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Golden Nugget Atlantic City', region: 'USA – East Coast', city: 'Atlantic City, NJ', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'MGM National Harbor', region: 'USA – East Coast', city: 'Oxon Hill, MD', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Live! Casino Hotel Maryland', region: 'USA – East Coast', city: 'Hanover, MD', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Foxwoods Resort Casino', region: 'USA – East Coast', city: 'Mashantucket, CT', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Mohegan Sun', region: 'USA – East Coast', city: 'Uncasville, CT', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Turning Stone Resort Casino', region: 'USA – East Coast', city: 'Verona, NY', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Resorts World New York City', region: 'USA – East Coast', city: 'Jamaica, NY', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'MGM Springfield', region: 'USA – East Coast', city: 'Springfield, MA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Encore Boston Harbor', region: 'USA – East Coast', city: 'Everett, MA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Twin River Casino Hotel', region: 'USA – East Coast', city: 'Lincoln, RI', currency: 'USD', country: 'USA'),

  // ── USA – Midwest ────────────────────────────────────────────────────────────
  PokerRoom(name: 'Rivers Casino Des Plaines', region: 'USA – Midwest', city: 'Des Plaines, IL', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Horseshoe Hammond', region: 'USA – Midwest', city: 'Hammond, IN', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'JACK Cleveland Casino', region: 'USA – Midwest', city: 'Cleveland, OH', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'JACK Cincinnati Casino', region: 'USA – Midwest', city: 'Cincinnati, OH', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Hollywood Casino Columbus', region: 'USA – Midwest', city: 'Columbus, OH', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'MotorCity Casino', region: 'USA – Midwest', city: 'Detroit, MI', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'FireKeepers Casino Hotel', region: 'USA – Midwest', city: 'Battle Creek, MI', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Four Winds New Buffalo', region: 'USA – Midwest', city: 'New Buffalo, MI', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Ameristar Casino St. Charles', region: 'USA – Midwest', city: 'St. Charles, MO', currency: 'USD', country: 'USA'),

  // ── USA – South ──────────────────────────────────────────────────────────────
  PokerRoom(name: 'Seminole Hard Rock Hollywood', region: 'USA – South', city: 'Hollywood, FL', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Seminole Hard Rock Tampa', region: 'USA – South', city: 'Tampa, FL', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Seminole Casino Coconut Creek', region: 'USA – South', city: 'Coconut Creek, FL', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Harrah\'s Cherokee Casino Resort', region: 'USA – South', city: 'Cherokee, NC', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'WinStar World Casino', region: 'USA – South', city: 'Thackerville, OK', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Choctaw Casino Durant', region: 'USA – South', city: 'Durant, OK', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'L\'Auberge Casino Lake Charles', region: 'USA – South', city: 'Lake Charles, LA', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'Beau Rivage Resort Casino', region: 'USA – South', city: 'Biloxi, MS', currency: 'USD', country: 'USA'),
  PokerRoom(name: 'IP Casino Biloxi', region: 'USA – South', city: 'Biloxi, MS', currency: 'USD', country: 'USA'),

  // ── United Kingdom ────────────────────────────────────────────────────────────
  PokerRoom(name: 'The Hippodrome Casino', region: 'United Kingdom', city: 'London, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Aspers Casino Stratford', region: 'United Kingdom', city: 'London, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Grosvenor Victoria Casino', region: 'United Kingdom', city: 'London, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Grosvenor Casino Leeds', region: 'United Kingdom', city: 'Leeds, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Grosvenor Casino Manchester', region: 'United Kingdom', city: 'Manchester, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Dusk Till Dawn', region: 'United Kingdom', city: 'Nottingham, UK', currency: 'GBP', country: 'United Kingdom'),
  PokerRoom(name: 'Napoleons Casino Sheffield', region: 'United Kingdom', city: 'Sheffield, UK', currency: 'GBP', country: 'United Kingdom'),

  // ── Europe ────────────────────────────────────────────────────────────────────
  PokerRoom(name: 'Casino de Monte-Carlo', region: 'Europe', city: 'Monaco', currency: 'EUR', country: 'Monaco'),
  PokerRoom(name: 'Kings Casino', region: 'Europe', city: 'Rozvadov, Czech Republic', currency: 'EUR', country: 'Czech Republic'),
  PokerRoom(name: 'Grand Casino Brussels', region: 'Europe', city: 'Brussels, Belgium', currency: 'EUR', country: 'Belgium'),
  PokerRoom(name: 'Casino Barcelona', region: 'Europe', city: 'Barcelona, Spain', currency: 'EUR', country: 'Spain'),
  PokerRoom(name: 'Casino de Paris', region: 'Europe', city: 'Paris, France', currency: 'EUR', country: 'France'),
  PokerRoom(name: 'Casino Wiesbaden', region: 'Europe', city: 'Wiesbaden, Germany', currency: 'EUR', country: 'Germany'),
  PokerRoom(name: 'Holland Casino Amsterdam', region: 'Europe', city: 'Amsterdam, Netherlands', currency: 'EUR', country: 'Netherlands'),
  PokerRoom(name: 'Casino di Venezia', region: 'Europe', city: 'Venice, Italy', currency: 'EUR', country: 'Italy'),

  // ── Australia / NZ ───────────────────────────────────────────────────────────
  PokerRoom(name: 'Crown Melbourne', region: 'Australia / NZ', city: 'Melbourne, VIC', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'Crown Perth', region: 'Australia / NZ', city: 'Perth, WA', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'The Star Sydney', region: 'Australia / NZ', city: 'Sydney, NSW', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'The Star Gold Coast', region: 'Australia / NZ', city: 'Gold Coast, QLD', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'Treasury Brisbane', region: 'Australia / NZ', city: 'Brisbane, QLD', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'SkyCity Adelaide', region: 'Australia / NZ', city: 'Adelaide, SA', currency: 'AUD', country: 'Australia'),
  PokerRoom(name: 'Sky City Auckland', region: 'Australia / NZ', city: 'Auckland, NZ', currency: 'NZD', country: 'New Zealand'),
  PokerRoom(name: 'SkyCity Hamilton', region: 'Australia / NZ', city: 'Hamilton, NZ', currency: 'NZD', country: 'New Zealand'),
];
