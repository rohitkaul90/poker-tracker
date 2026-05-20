class PokerRoom {
  final String name;
  final String region;
  final String city;
  final String currency;
  final bool isOnline;

  const PokerRoom({
    required this.name,
    required this.region,
    required this.city,
    required this.currency,
    this.isOnline = false,
  });

  String get storageKey => isOnline ? 'Online – $name' : name;
  String get subtitle => isOnline ? 'Online' : city;
}

bool isOnlineSession(String? location) => location?.startsWith('Online –') ?? false;

const kPokerRooms = <PokerRoom>[
  // ── Online ──────────────────────────────────────────────────────────────────
  PokerRoom(name: 'PokerStars', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'GGPoker', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'partypoker', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: '888poker', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'Americas Cardroom', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'WSOP.com', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'BetOnline', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'Bovada Poker', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'WPN (Winning Poker Network)', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'PokerKing', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'Ignition Casino', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'Natural8', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),
  PokerRoom(name: 'iPoker Network', region: 'Online', city: 'Online', currency: 'USD', isOnline: true),

  // ── Canada – Ontario ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Woodbine Casino', region: 'Canada – Ontario', city: 'Toronto, ON', currency: 'CAD'),
  PokerRoom(name: 'Pickering Casino Resort', region: 'Canada – Ontario', city: 'Pickering, ON', currency: 'CAD'),
  PokerRoom(name: 'Elements Casino Ajax', region: 'Canada – Ontario', city: 'Ajax, ON', currency: 'CAD'),
  PokerRoom(name: 'Elements Casino Flamboro', region: 'Canada – Ontario', city: 'Dundas, ON', currency: 'CAD'),
  PokerRoom(name: 'Elements Casino Mohawk', region: 'Canada – Ontario', city: 'Campbellville, ON', currency: 'CAD'),
  PokerRoom(name: 'Elements Casino Grand River', region: 'Canada – Ontario', city: 'Elora, ON', currency: 'CAD'),
  PokerRoom(name: 'Elements Casino Brantford', region: 'Canada – Ontario', city: 'Brantford, ON', currency: 'CAD'),
  PokerRoom(name: 'Casino Rama Resort', region: 'Canada – Ontario', city: 'Orillia, ON', currency: 'CAD'),
  PokerRoom(name: 'Great Blue Heron Casino', region: 'Canada – Ontario', city: 'Port Perry, ON', currency: 'CAD'),
  PokerRoom(name: 'Fallsview Casino Resort', region: 'Canada – Ontario', city: 'Niagara Falls, ON', currency: 'CAD'),
  PokerRoom(name: 'Casino Niagara', region: 'Canada – Ontario', city: 'Niagara Falls, ON', currency: 'CAD'),
  PokerRoom(name: 'Shorelines Casino Thousand Islands', region: 'Canada – Ontario', city: 'Gananoque, ON', currency: 'CAD'),
  PokerRoom(name: 'Shorelines Casino Belleville', region: 'Canada – Ontario', city: 'Belleville, ON', currency: 'CAD'),
  PokerRoom(name: 'Shorelines Casino Peterborough', region: 'Canada – Ontario', city: 'Peterborough, ON', currency: 'CAD'),
  PokerRoom(name: 'OLG Casino Ottawa', region: 'Canada – Ontario', city: 'Ottawa, ON', currency: 'CAD'),

  // ── Canada – Quebec ──────────────────────────────────────────────────────────
  PokerRoom(name: 'Playground Poker Club', region: 'Canada – Quebec', city: 'Kahnawake, QC', currency: 'CAD'),
  PokerRoom(name: 'Casino de Montréal', region: 'Canada – Quebec', city: 'Montreal, QC', currency: 'CAD'),
  PokerRoom(name: 'Casino Lac-Leamy', region: 'Canada – Quebec', city: 'Gatineau, QC', currency: 'CAD'),

  // ── Canada – Alberta ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Grey Eagle Resort & Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD'),
  PokerRoom(name: 'Elbow River Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD'),
  PokerRoom(name: 'Cash Casino Calgary', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD'),
  PokerRoom(name: 'River Cree Resort & Casino', region: 'Canada – Alberta', city: 'Edmonton, AB', currency: 'CAD'),
  PokerRoom(name: 'Palace Casino', region: 'Canada – Alberta', city: 'Edmonton, AB', currency: 'CAD'),
  PokerRoom(name: 'Deerfoot Inn & Casino', region: 'Canada – Alberta', city: 'Calgary, AB', currency: 'CAD'),

  // ── Canada – British Columbia ────────────────────────────────────────────────
  PokerRoom(name: 'Starlight Casino', region: 'Canada – British Columbia', city: 'New Westminster, BC', currency: 'CAD'),
  PokerRoom(name: 'Parq Vancouver', region: 'Canada – British Columbia', city: 'Vancouver, BC', currency: 'CAD'),
  PokerRoom(name: 'Hard Rock Casino Vancouver', region: 'Canada – British Columbia', city: 'Coquitlam, BC', currency: 'CAD'),
  PokerRoom(name: 'River Rock Casino Resort', region: 'Canada – British Columbia', city: 'Richmond, BC', currency: 'CAD'),
  PokerRoom(name: 'Chances Casino', region: 'Canada – British Columbia', city: 'Various, BC', currency: 'CAD'),

  // ── Canada – Manitoba ────────────────────────────────────────────────────────
  PokerRoom(name: 'Club Regent Casino', region: 'Canada – Manitoba', city: 'Winnipeg, MB', currency: 'CAD'),
  PokerRoom(name: 'McPhillips Station Casino', region: 'Canada – Manitoba', city: 'Winnipeg, MB', currency: 'CAD'),

  // ── Canada – Saskatchewan ────────────────────────────────────────────────────
  PokerRoom(name: 'Casino Regina', region: 'Canada – Saskatchewan', city: 'Regina, SK', currency: 'CAD'),
  PokerRoom(name: 'Casino Moose Jaw', region: 'Canada – Saskatchewan', city: 'Moose Jaw, SK', currency: 'CAD'),

  // ── USA – Las Vegas ──────────────────────────────────────────────────────────
  PokerRoom(name: 'Bellagio', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Wynn Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'ARIA Resort & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'The Venetian Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Caesars Palace', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Horseshoe Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'MGM Grand', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Resorts World Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Red Rock Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Paris Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Planet Hollywood Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'South Point Hotel & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'The Orleans Hotel & Casino', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Golden Nugget Las Vegas', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Binion\'s Gambling Hall', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Treasure Island', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),
  PokerRoom(name: 'Palms Casino Resort', region: 'USA – Las Vegas', city: 'Las Vegas, NV', currency: 'USD'),

  // ── USA – Los Angeles ────────────────────────────────────────────────────────
  PokerRoom(name: 'Commerce Casino', region: 'USA – Los Angeles', city: 'Commerce, CA', currency: 'USD'),
  PokerRoom(name: 'The Bicycle Casino', region: 'USA – Los Angeles', city: 'Bell Gardens, CA', currency: 'USD'),
  PokerRoom(name: 'Hustler Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD'),
  PokerRoom(name: 'Hollywood Park Casino', region: 'USA – Los Angeles', city: 'Inglewood, CA', currency: 'USD'),
  PokerRoom(name: 'Larry Flynt\'s Lucky Lady Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD'),
  PokerRoom(name: 'Normandie Casino', region: 'USA – Los Angeles', city: 'Gardena, CA', currency: 'USD'),
  PokerRoom(name: 'Hawaiian Gardens Casino', region: 'USA – Los Angeles', city: 'Hawaiian Gardens, CA', currency: 'USD'),

  // ── USA – Northern California ────────────────────────────────────────────────
  PokerRoom(name: 'Bay 101 Casino', region: 'USA – Northern California', city: 'San Jose, CA', currency: 'USD'),
  PokerRoom(name: 'Stones Gambling Hall', region: 'USA – Northern California', city: 'Sacramento, CA', currency: 'USD'),
  PokerRoom(name: 'Lucky Chances Casino', region: 'USA – Northern California', city: 'Colma, CA', currency: 'USD'),
  PokerRoom(name: 'The Oaks Card Club', region: 'USA – Northern California', city: 'Emeryville, CA', currency: 'USD'),
  PokerRoom(name: 'Cache Creek Casino Resort', region: 'USA – Northern California', city: 'Brooks, CA', currency: 'USD'),

  // ── USA – Pacific Northwest ──────────────────────────────────────────────────
  PokerRoom(name: 'Snoqualmie Casino', region: 'USA – Pacific Northwest', city: 'Snoqualmie, WA', currency: 'USD'),
  PokerRoom(name: 'Muckleshoot Casino', region: 'USA – Pacific Northwest', city: 'Auburn, WA', currency: 'USD'),
  PokerRoom(name: 'Tulalip Resort Casino', region: 'USA – Pacific Northwest', city: 'Tulalip, WA', currency: 'USD'),
  PokerRoom(name: 'Ilani Casino Resort', region: 'USA – Pacific Northwest', city: 'Ridgefield, WA', currency: 'USD'),
  PokerRoom(name: 'Chinook Winds Casino Resort', region: 'USA – Pacific Northwest', city: 'Lincoln City, OR', currency: 'USD'),

  // ── USA – Arizona ────────────────────────────────────────────────────────────
  PokerRoom(name: 'Talking Stick Resort', region: 'USA – Arizona', city: 'Scottsdale, AZ', currency: 'USD'),
  PokerRoom(name: 'Casino Arizona at Salt River', region: 'USA – Arizona', city: 'Scottsdale, AZ', currency: 'USD'),
  PokerRoom(name: 'Harrah\'s Ak-Chin Casino', region: 'USA – Arizona', city: 'Maricopa, AZ', currency: 'USD'),

  // ── USA – East Coast ─────────────────────────────────────────────────────────
  PokerRoom(name: 'Borgata Hotel Casino', region: 'USA – East Coast', city: 'Atlantic City, NJ', currency: 'USD'),
  PokerRoom(name: 'Harrah\'s Philadelphia', region: 'USA – East Coast', city: 'Chester, PA', currency: 'USD'),
  PokerRoom(name: 'Rivers Casino Philadelphia', region: 'USA – East Coast', city: 'Philadelphia, PA', currency: 'USD'),
  PokerRoom(name: 'Golden Nugget Atlantic City', region: 'USA – East Coast', city: 'Atlantic City, NJ', currency: 'USD'),
  PokerRoom(name: 'MGM National Harbor', region: 'USA – East Coast', city: 'Oxon Hill, MD', currency: 'USD'),
  PokerRoom(name: 'Live! Casino Hotel Maryland', region: 'USA – East Coast', city: 'Hanover, MD', currency: 'USD'),
  PokerRoom(name: 'Foxwoods Resort Casino', region: 'USA – East Coast', city: 'Mashantucket, CT', currency: 'USD'),
  PokerRoom(name: 'Mohegan Sun', region: 'USA – East Coast', city: 'Uncasville, CT', currency: 'USD'),
  PokerRoom(name: 'Turning Stone Resort Casino', region: 'USA – East Coast', city: 'Verona, NY', currency: 'USD'),
  PokerRoom(name: 'Resorts World New York City', region: 'USA – East Coast', city: 'Jamaica, NY', currency: 'USD'),
  PokerRoom(name: 'MGM Springfield', region: 'USA – East Coast', city: 'Springfield, MA', currency: 'USD'),
  PokerRoom(name: 'Encore Boston Harbor', region: 'USA – East Coast', city: 'Everett, MA', currency: 'USD'),
  PokerRoom(name: 'Twin River Casino Hotel', region: 'USA – East Coast', city: 'Lincoln, RI', currency: 'USD'),

  // ── USA – Midwest ────────────────────────────────────────────────────────────
  PokerRoom(name: 'Rivers Casino Des Plaines', region: 'USA – Midwest', city: 'Des Plaines, IL', currency: 'USD'),
  PokerRoom(name: 'Horseshoe Hammond', region: 'USA – Midwest', city: 'Hammond, IN', currency: 'USD'),
  PokerRoom(name: 'JACK Cleveland Casino', region: 'USA – Midwest', city: 'Cleveland, OH', currency: 'USD'),
  PokerRoom(name: 'JACK Cincinnati Casino', region: 'USA – Midwest', city: 'Cincinnati, OH', currency: 'USD'),
  PokerRoom(name: 'Hollywood Casino Columbus', region: 'USA – Midwest', city: 'Columbus, OH', currency: 'USD'),
  PokerRoom(name: 'MotorCity Casino', region: 'USA – Midwest', city: 'Detroit, MI', currency: 'USD'),
  PokerRoom(name: 'FireKeepers Casino Hotel', region: 'USA – Midwest', city: 'Battle Creek, MI', currency: 'USD'),
  PokerRoom(name: 'Four Winds New Buffalo', region: 'USA – Midwest', city: 'New Buffalo, MI', currency: 'USD'),
  PokerRoom(name: 'Ameristar Casino St. Charles', region: 'USA – Midwest', city: 'St. Charles, MO', currency: 'USD'),

  // ── USA – South ──────────────────────────────────────────────────────────────
  PokerRoom(name: 'Seminole Hard Rock Hollywood', region: 'USA – South', city: 'Hollywood, FL', currency: 'USD'),
  PokerRoom(name: 'Seminole Hard Rock Tampa', region: 'USA – South', city: 'Tampa, FL', currency: 'USD'),
  PokerRoom(name: 'Seminole Casino Coconut Creek', region: 'USA – South', city: 'Coconut Creek, FL', currency: 'USD'),
  PokerRoom(name: 'Harrah\'s Cherokee Casino Resort', region: 'USA – South', city: 'Cherokee, NC', currency: 'USD'),
  PokerRoom(name: 'WinStar World Casino', region: 'USA – South', city: 'Thackerville, OK', currency: 'USD'),
  PokerRoom(name: 'Choctaw Casino Durant', region: 'USA – South', city: 'Durant, OK', currency: 'USD'),
  PokerRoom(name: 'L\'Auberge Casino Lake Charles', region: 'USA – South', city: 'Lake Charles, LA', currency: 'USD'),
  PokerRoom(name: 'Beau Rivage Resort Casino', region: 'USA – South', city: 'Biloxi, MS', currency: 'USD'),
  PokerRoom(name: 'IP Casino Biloxi', region: 'USA – South', city: 'Biloxi, MS', currency: 'USD'),

  // ── United Kingdom ────────────────────────────────────────────────────────────
  PokerRoom(name: 'The Hippodrome Casino', region: 'United Kingdom', city: 'London, UK', currency: 'GBP'),
  PokerRoom(name: 'Aspers Casino Stratford', region: 'United Kingdom', city: 'London, UK', currency: 'GBP'),
  PokerRoom(name: 'Grosvenor Victoria Casino', region: 'United Kingdom', city: 'London, UK', currency: 'GBP'),
  PokerRoom(name: 'Grosvenor Casino Leeds', region: 'United Kingdom', city: 'Leeds, UK', currency: 'GBP'),
  PokerRoom(name: 'Grosvenor Casino Manchester', region: 'United Kingdom', city: 'Manchester, UK', currency: 'GBP'),
  PokerRoom(name: 'Dusk Till Dawn', region: 'United Kingdom', city: 'Nottingham, UK', currency: 'GBP'),
  PokerRoom(name: 'Napoleons Casino Sheffield', region: 'United Kingdom', city: 'Sheffield, UK', currency: 'GBP'),

  // ── Europe ────────────────────────────────────────────────────────────────────
  PokerRoom(name: 'Casino de Monte-Carlo', region: 'Europe', city: 'Monaco', currency: 'EUR'),
  PokerRoom(name: 'Kings Casino', region: 'Europe', city: 'Rozvadov, Czech Republic', currency: 'EUR'),
  PokerRoom(name: 'Grand Casino Brussels', region: 'Europe', city: 'Brussels, Belgium', currency: 'EUR'),
  PokerRoom(name: 'Casino Barcelona', region: 'Europe', city: 'Barcelona, Spain', currency: 'EUR'),
  PokerRoom(name: 'Casino de Paris', region: 'Europe', city: 'Paris, France', currency: 'EUR'),
  PokerRoom(name: 'Casino Wiesbaden', region: 'Europe', city: 'Wiesbaden, Germany', currency: 'EUR'),
  PokerRoom(name: 'Holland Casino Amsterdam', region: 'Europe', city: 'Amsterdam, Netherlands', currency: 'EUR'),
  PokerRoom(name: 'Casino di Venezia', region: 'Europe', city: 'Venice, Italy', currency: 'EUR'),

  // ── Australia / NZ ───────────────────────────────────────────────────────────
  PokerRoom(name: 'Crown Melbourne', region: 'Australia / NZ', city: 'Melbourne, VIC', currency: 'AUD'),
  PokerRoom(name: 'Crown Perth', region: 'Australia / NZ', city: 'Perth, WA', currency: 'AUD'),
  PokerRoom(name: 'The Star Sydney', region: 'Australia / NZ', city: 'Sydney, NSW', currency: 'AUD'),
  PokerRoom(name: 'The Star Gold Coast', region: 'Australia / NZ', city: 'Gold Coast, QLD', currency: 'AUD'),
  PokerRoom(name: 'Treasury Brisbane', region: 'Australia / NZ', city: 'Brisbane, QLD', currency: 'AUD'),
  PokerRoom(name: 'SkyCity Adelaide', region: 'Australia / NZ', city: 'Adelaide, SA', currency: 'AUD'),
  PokerRoom(name: 'Sky City Auckland', region: 'Australia / NZ', city: 'Auckland, NZ', currency: 'NZD'),
  PokerRoom(name: 'SkyCity Hamilton', region: 'Australia / NZ', city: 'Hamilton, NZ', currency: 'NZD'),
];
