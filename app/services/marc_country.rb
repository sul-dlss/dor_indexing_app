# frozen_string_literal: true

class MarcCountry
  MARC_COUNTRY_URI = 'http://id.loc.gov/vocabulary/countries/'

  MARC_COUNTRY_CODE = 'marccountry'

  COUNTRY_CODES = {
    'aa' => 'Albania',
    'abc' => 'Alberta',
    'aca' => 'Australian Capital Territory',
    'ae' => 'Algeria',
    'af' => 'Afghanistan',
    'ag' => 'Argentina',
    'ai' => 'Armenia (Republic)',
    'aj' => 'Azerbaijan',
    'aku' => 'Alaska',
    'alu' => 'Alabama',
    'am' => 'Anguilla',
    'an' => 'Andorra',
    'ao' => 'Angola',
    'aq' => 'Antigua and Barbuda',
    'aru' => 'Arkansas',
    'as' => 'American Samoa',
    'at' => 'Australia',
    'au' => 'Austria',
    'aw' => 'Aruba',
    'ay' => 'Antarctica',
    'azu' => 'Arizona',
    'ba' => 'Bahrain',
    'bb' => 'Barbados',
    'bcc' => 'British Columbia',
    'bd' => 'Burundi',
    'be' => 'Belgium',
    'bf' => 'Bahamas',
    'bg' => 'Bangladesh',
    'bh' => 'Belize',
    'bi' => 'British Indian Ocean Territory',
    'bl' => 'Brazil',
    'bm' => 'Bermuda Islands',
    'bn' => 'Bosnia and Herzegovina',
    'bo' => 'Bolivia',
    'bp' => 'Solomon Islands',
    'br' => 'Burma',
    'bs' => 'Botswana',
    'bt' => 'Bhutan',
    'bu' => 'Bulgaria',
    'bv' => 'Bouvet Island',
    'bw' => 'Belarus',
    'bx' => 'Brunei',
    'ca' => 'Caribbean Netherlands',
    'cau' => 'California',
    'cb' => 'Cambodia',
    'cc' => 'China',
    'cd' => 'Chad',
    'ce' => 'Sri Lanka',
    'cf' => 'Congo (Brazzaville)',
    'cg' => 'Congo (Democratic Republic)',
    'ch' => 'China (Republic : 1949- )',
    'ci' => 'Croatia',
    'cj' => 'Cayman Islands',
    'ck' => 'Colombia',
    'cl' => 'Chile',
    'cm' => 'Cameroon',
    'co' => 'Curaçao',
    'cou' => 'Colorado',
    'cq' => 'Comoros',
    'cr' => 'Costa Rica',
    'ctu' => 'Connecticut',
    'cu' => 'Cuba',
    'cv' => 'Cabo Verde',
    'cw' => 'Cook Islands',
    'cx' => 'Central African Republic',
    'cy' => 'Cyprus',
    'dcu' => 'District of Columbia',
    'deu' => 'Delaware',
    'dk' => 'Denmark',
    'dm' => 'Benin',
    'dq' => 'Dominica',
    'dr' => 'Dominican Republic',
    'ea' => 'Eritrea',
    'ec' => 'Ecuador',
    'eg' => 'Equatorial Guinea',
    'em' => 'Timor-Leste',
    'enk' => 'England',
    'er' => 'Estonia',
    'es' => 'El Salvador',
    'et' => 'Ethiopia',
    'fa' => 'Faroe Islands',
    'fg' => 'French Guiana',
    'fi' => 'Finland',
    'fj' => 'Fiji',
    'fk' => 'Falkland Islands',
    'flu' => 'Florida',
    'fm' => 'Micronesia (Federated States)',
    'fp' => 'French Polynesia',
    'fr' => 'France',
    'fs' => 'Terres australes et antarctiques françaises',
    'ft' => 'Djibouti',
    'gau' => 'Georgia',
    'gb' => 'Kiribati',
    'gd' => 'Grenada',
    'gg' => 'Guernsey',
    'gh' => 'Ghana',
    'gi' => 'Gibraltar',
    'gl' => 'Greenland',
    'gm' => 'Gambia',
    'go' => 'Gabon',
    'gp' => 'Guadeloupe',
    'gr' => 'Greece',
    'gs' => 'Georgia (Republic)',
    'gt' => 'Guatemala',
    'gu' => 'Guam',
    'gv' => 'Guinea',
    'gw' => 'Germany',
    'gy' => 'Guyana',
    'gz' => 'Gaza Strip',
    'hiu' => 'Hawaii',
    'hm' => 'Heard and McDonald Islands',
    'ho' => 'Honduras',
    'ht' => 'Haiti',
    'hu' => 'Hungary',
    'iau' => 'Iowa',
    'ic' => 'Iceland',
    'idu' => 'Idaho',
    'ie' => 'Ireland',
    'ii' => 'India',
    'ilu' => 'Illinois',
    'im' => 'Isle of Man',
    'inu' => 'Indiana',
    'io' => 'Indonesia',
    'iq' => 'Iraq',
    'ir' => 'Iran',
    'is' => 'Israel',
    'it' => 'Italy',
    'iv' => "Côte d'Ivoire",
    'iy' => 'Iraq-Saudi Arabia Neutral Zone',
    'ja' => 'Japan',
    'je' => 'Jersey',
    'ji' => 'Johnston Atoll',
    'jm' => 'Jamaica',
    'jo' => 'Jordan',
    'ke' => 'Kenya',
    'kg' => 'Kyrgyzstan',
    'kn' => 'Korea (North)',
    'ko' => 'Korea (South)',
    'ksu' => 'Kansas',
    'ku' => 'Kuwait',
    'kv' => 'Kosovo',
    'kyu' => 'Kentucky',
    'kz' => 'Kazakhstan',
    'lau' => 'Louisiana',
    'lb' => 'Liberia',
    'le' => 'Lebanon',
    'lh' => 'Liechtenstein',
    'li' => 'Lithuania',
    'lo' => 'Lesotho',
    'ls' => 'Laos',
    'lu' => 'Luxembourg',
    'lv' => 'Latvia',
    'ly' => 'Libya',
    'mau' => 'Massachusetts',
    'mbc' => 'Manitoba',
    'mc' => 'Monaco',
    'mdu' => 'Maryland',
    'meu' => 'Maine',
    'mf' => 'Mauritius',
    'mg' => 'Madagascar',
    'miu' => 'Michigan',
    'mj' => 'Montserrat',
    'mk' => 'Oman',
    'ml' => 'Mali',
    'mm' => 'Malta',
    'mnu' => 'Minnesota',
    'mo' => 'Montenegro',
    'mou' => 'Missouri',
    'mp' => 'Mongolia',
    'mq' => 'Martinique',
    'mr' => 'Morocco',
    'msu' => 'Mississippi',
    'mtu' => 'Montana',
    'mu' => 'Mauritania',
    'mv' => 'Moldova',
    'mw' => 'Malawi',
    'mx' => 'Mexico',
    'my' => 'Malaysia',
    'mz' => 'Mozambique',
    'nbu' => 'Nebraska',
    'ncu' => 'North Carolina',
    'ndu' => 'North Dakota',
    'ne' => 'Netherlands',
    'nfc' => 'Newfoundland and Labrador',
    'ng' => 'Niger',
    'nhu' => 'New Hampshire',
    'nik' => 'Northern Ireland',
    'nju' => 'New Jersey',
    'nkc' => 'New Brunswick',
    'nl' => 'New Caledonia',
    'nmu' => 'New Mexico',
    'nn' => 'Vanuatu',
    'no' => 'Norway',
    'np' => 'Nepal',
    'nq' => 'Nicaragua',
    'nr' => 'Nigeria',
    'nsc' => 'Nova Scotia',
    'ntc' => 'Northwest Territories',
    'nu' => 'Nauru',
    'nuc' => 'Nunavut',
    'nvu' => 'Nevada',
    'nw' => 'Northern Mariana Islands',
    'nx' => 'Norfolk Island',
    'nyu' => 'New York (State)',
    'nz' => 'New Zealand',
    'ohu' => 'Ohio',
    'oku' => 'Oklahoma',
    'onc' => 'Ontario',
    'oru' => 'Oregon',
    'ot' => 'Mayotte',
    'pau' => 'Pennsylvania',
    'pc' => 'Pitcairn Island',
    'pe' => 'Peru',
    'pf' => 'Paracel Islands]',
    'pg' => 'Guinea-Bissau',
    'ph' => 'Philippines',
    'pic' => 'Prince Edward Island',
    'pk' => 'Pakistan',
    'pl' => 'Poland',
    'pn' => 'Panama',
    'po' => 'Portugal',
    'pp' => 'Papua New Guinea',
    'pr' => 'Puerto Rico',
    'pw' => 'Palau',
    'py' => 'Paraguay',
    'qa' => 'Qatar',
    'qea' => 'Queensland',
    'quc' => 'Québec (Province)',
    'rb' => 'Serbia',
    're' => 'Réunion',
    'rh' => 'Zimbabwe',
    'riu' => 'Rhode Island',
    'rm' => 'Romania',
    'ru' => 'Russia (Federation)',
    'rw' => 'Rwanda',
    'sa' => 'South Africa',
    'sc' => 'Saint-Barthélemy',
    'scu' => 'South Carolina',
    'sd' => 'South Sudan',
    'sdu' => 'South Dakota',
    'se' => 'Seychelles',
    'sf' => 'Sao Tome and Principe',
    'sg' => 'Senegal',
    'sh' => 'Spanish North Africa',
    'si' => 'Singapore',
    'sj' => 'Sudan',
    'sl' => 'Sierra Leone',
    'sm' => 'San Marino',
    'sn' => 'Sint Maarten',
    'snc' => 'Saskatchewan',
    'so' => 'Somalia',
    'sp' => 'Spain',
    'sq' => 'Eswatini',
    'sr' => 'Surinam',
    'ss' => 'Western Sahara',
    'st' => 'Saint-Martin',
    'stk' => 'Scotland',
    'su' => 'Saudi Arabia',
    'sw' => 'Sweden',
    'sx' => 'Namibia',
    'sy' => 'Syria',
    'sz' => 'Switzerland',
    'ta' => 'Tajikistan',
    'tc' => 'Turks and Caicos Islands',
    'tg' => 'Togo',
    'th' => 'Thailand',
    'ti' => 'Tunisia',
    'tk' => 'Turkmenistan',
    'tl' => 'Tokelau',
    'tma' => 'Tasmania',
    'tnu' => 'Tennessee',
    'to' => 'Tonga',
    'tr' => 'Trinidad and Tobago',
    'ts' => 'United Arab Emirates',
    'tu' => 'Turkey',
    'tv' => 'Tuvalu',
    'txu' => 'Texas',
    'tz' => 'Tanzania',
    'ua' => 'Egypt',
    'uc' => 'United States Misc. Caribbean Islands',
    'ug' => 'Uganda',
    'un' => 'Ukraine',
    'up' => 'United States Misc. Pacific Islands',
    'utu' => 'Utah',
    'uv' => 'Burkina Faso',
    'uy' => 'Uruguay',
    'uz' => 'Uzbekistan',
    'vau' => 'Virginia',
    'vb' => 'British Virgin Islands',
    'vc' => 'Vatican City',
    've' => 'Venezuela',
    'vi' => 'Virgin Islands of the United States',
    'vm' => 'Vietnam',
    'vp' => 'Various places',
    'vra' => 'Victoria',
    'vtu' => 'Vermont',
    'wau' => 'Washington (State)',
    'wea' => 'Western Australia',
    'wf' => 'Wallis and Futuna',
    'wiu' => 'Wisconsin',
    'wj' => 'West Bank of the Jordan River',
    'wk' => 'Wake Island',
    'wlk' => 'Wales',
    'ws' => 'Samoa',
    'wvu' => 'West Virginia',
    'wyu' => 'Wyoming',
    'xa' => 'Christmas Island (Indian Ocean)',
    'xb' => 'Cocos (Keeling) Islands',
    'xc' => 'Maldives',
    'xd' => 'Saint Kitts-Nevis',
    'xe' => 'Marshall Islands',
    'xf' => 'Midway Islands',
    'xga' => 'Coral Sea Islands Territory',
    'xh' => 'Niue',
    'xj' => 'Saint Helena',
    'xk' => 'Saint Lucia',
    'xl' => 'Saint Pierre and Miquelon',
    'xm' => 'Saint Vincent and the Grenadines',
    'xn' => 'North Macedonia',
    'xna' => 'New South Wales',
    'xo' => 'Slovakia',
    'xoa' => 'Northern Territory',
    'xp' => 'Spratly Island',
    'xr' => 'Czech Republic',
    'xra' => 'South Australia',
    'xs' => 'South Georgia and the South Sandwich Islands',
    'xv' => 'Slovenia',
    'xx' => '"No place, unknown, or undetermined"',
    'xxc' => 'Canada',
    'xxk' => 'United Kingdom',
    'xxu' => 'United States',
    'ye' => 'Yemen',
    'ykc' => 'Yukon Territory',
    'za' => 'Zambia'
  }.freeze

  def self.from_code(code)
    COUNTRY_CODES[code]
  end

  def self.from_uri(uri)
    return unless uri&.start_with?('http://id.loc.gov/vocabulary/countries/')

    COUNTRY_CODES[uri[MARC_COUNTRY_URI.length..]]
  end
end
