
# MFeed 

> Developed with Xcode 11.7 and compatible with iOS 13+  

MFeed is a **demo** app made in pure SwiftUI where users can share songs that they listened to or just like to a feed where their friends can see and interact. Each shared song instance to the feed is considered a "tweet". Friends can interact by liking these tweets, saving them to listen to later, or even comment. Users also have their own profile where they can toggle genres for friends to see what they prefer to listen to, access received follow requests, and also showcase the last song that they shared to the feed. 

## Background 

### Design 

#### *MVVM* 
The project is structured around the MVVM design where we have Models, ViewModels, and Views. The design pattern is how we can separate out concerns over UI and business logic. Compared to the traditional MVC pattern (Model, View, Controller), the introduction of ViewModels allows for a better segway between UI and business logic. The one downside of Controllers is that they can grow unwieldy and pretty large. After all, the Views should not be responsible for coordinating/fetching/updating information to render a view, and the Model only concerns itself with CRUD operations with the database and other business logic (e.g. what information should a song "tweet" have?). ViewModels allow for a better, more customized way of coordinating information for multiple instances of a View. 

#### *CoreData*  

CoreData is an object graph representation of the underlying database for the project. At first glance, it seems to be just the database, but that's not how Apple intended it to be used as. For this project, the underlying database is a regular SQLite DB. What CoreData provides is an API for CRUD operations more easily than regular DB operations. For instance, there is no need to implement your own primary and foreign keys like with SQL as CoreData does that for you behind-the-scenes. 

Getting used to CoreData can take a while and the major example  that made me realize how it makes life easier is how it deals with many-to-many (M:M) relationships. In most database schemas, to represent a M:M relationship between two entities (e.g. A, B) , you need an intersection entity that has the primary keys of both A and B. But with CoreData, I just need to fetch the results of A and filter with a predicate based on B. There is no need to create another entity to just soak up the results for querying later. 

### Implementation 
The 3 main directories to look at are "Models", "ViewModels", and "Views". 

1.  Models -> defined all the relevant objects in our system such as "Comment", "SongInstance", "User". These (struct) objects properly encapsulate how the app sends and receives information. The most important object is the "TestDataManager" class that does the heavy lifting performing the CRUD operations with CoreData. In short, think of this class as dealing with the "database" 
2. ViewModels -> some views of the app depend on certain information. For instance, if I look at my profile, I can toggle my genres, but this would be read-only information for my friends, and strangers cannot see this info at all. As such, the ViewModels handle all the different functionalities behind the music tweets, profile views, etc.
3. Views -> The actual UI that users can see on their iPhone screens. The core views are the Feed, Profile, and SongComment views. The Feed is where all songs are shared and can be interacted with and the Profile is self-explanatory. The SongComment view is where a user clicks on the "Convo" button on a music tweet and is taken to a view where they can see all the comments said about a song (and can also contribute their own) 
