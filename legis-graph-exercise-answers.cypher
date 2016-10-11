// 
// legis-graph US Congress Neo4j Exercise Answers
//
//  access here: bit.ly/neo4jgraph

//
// Get familiar with the data... basic lookups
//

// Find senator Barrasso
MATCH (l:Legislator) 
WHERE l.lastName = "Barrasso" 
RETURN l;

// Now try to find a legislator called 'Johnson', filters on non unique properties may return multiple results!
MATCH (l:Legislator) 
WHERE l.lastName = "Johnson" 
RETURN l;


// Identify unique identifiers for the entities in your graph
// If this query returns values then lastName is not unique:
MATCH (l:Legislator) 
WITH l.lastName AS attValue, count(*) AS count 
WHERE count > 1 
RETURN *;


// Find bills mentioning Cuba in its title
MATCH (b:Bill)
WHERE b.officialTitle CONTAINS "Cuba"
RETURN b;


// Find legislators older than 65 and with name ending in 'son'
MATCH (l:Legislator)
WHERE l.birthday < "1971" AND l.lastName ENDS WITH "son"
RETURN l;


//
// Get familiar with the data... let's start building patterns
//


// Find the bills referred to the House Committee on Agriculture that mention livestock in their title
MATCH (b:Bill)-[:REFERRED_TO]->(c:Committee)
WHERE c.name CONTAINS "House Committee on Agriculture" 
AND b.officialTitle CONTAINS "livestock"
RETURN *;


//
// Explore by state
//

// Who are the legislators that represent NY?
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
RETURN s,l;


// What political parties do they represent?
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
MATCH (l)-[:IS_MEMBER_OF]-(p:Party)
RETURN DISTINCT p.name;


// How many NY Democrats are serving in the House?
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
MATCH (p:Party)<-[:IS_MEMBER_OF]-(l)-[:ELECTED_TO]->(b:Body)
RETURN p.name, b.type, count(*) AS num ORDER BY num DESC;


//
// Committees
//

// For the legislators representing NY, what are the Committees on which they serve?

// Graph view
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
MATCH (l)-[:SERVES_ON]->(c:Committee)
RETURN l,c;


// Distinct committees
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
MATCH (l)-[:SERVES_ON]->(c:Committee)
RETURN DISTINCT c;


// What are the subjects of the bills referred to these committees?
MATCH (l:Legislator)-[:REPRESENTS]->(s:State)
WHERE s.code = "NY"
MATCH (l)-[:SERVES_ON]->(c:Committee)
MATCH (c)<-[:REFERRED_TO]-(b:Bill)-[:DEALS_WITH]->(topic:Subject)
RETURN topic.title, COUNT(*) AS num ORDER BY num DESC;


// 
// Bill Sponsorhip
//


// Who sponsors the most bills?
MATCH (l:Legislator)<-[:SPONSORED_BY]-(b:Bill)
RETURN l.firstName + " " + l.lastName AS legislator, COUNT(*) AS num
ORDER BY num DESC;

// Who sponsors the most bills for the subject "News media and reporting"
MATCH (s:Subject) WHERE s.title CONTAINS "News media and reporting"
MATCH (s)<-[:DEALS_WITH]-(:Bill)-[:SPONSORED_BY]->(l:Legislator)
RETURN l.firstName + " " + l.lastName AS legislator, COUNT(*) AS num 
ORDER BY num DESC;

// Which legislators frequently sponsor bills together?
MATCH (l1:Legislator)<-[:SPONSORED_BY]-(:Bill)-[:SPONSORED_BY]->(l2:Legislator)
WHERE id(l1) < id(l2)
RETURN l1.firstName + " " + l1.lastName AS legislator1, 
       l2.firstName + " " + l2.lastName AS legislator2,
       COUNT(*) AS num
ORDER BY num DESC LIMIT 10;


// Choose a specific legislator and find the subjects of the bills this legislator sponsors. What are the most common subjects
MATCH (l:Legislator) 
WHERE l.firstName = "Charles" AND l.lastName = "Rangel"
MATCH (l)<-[:SPONSORED_BY]-(:Bill)-[:DEALS_WITH]->(s:Subject)
RETURN s.title, COUNT(*) AS num ORDER BY num DESC;


// (Bonus) Only include bills where this legislator was the main sponsor
MATCH (l:Legislator) 
WHERE l.firstName = "Charles" AND l.lastName = "Rangel"
MATCH (l)<-[r:SPONSORED_BY]-(:Bill)-[:DEALS_WITH]->(s:Subject)
WHERE r.cosponsor = "0"
RETURN s.title, COUNT(*) AS num ORDER BY num DESC;