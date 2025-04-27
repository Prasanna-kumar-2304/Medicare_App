import 'package:flutter/material.dart';

class RefundPage extends StatelessWidget {
  const RefundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Return page'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // back button action
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            'Return items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ReturnItemCard(),
          SizedBox(height: 30),
          Text(
            'Old Return items',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          OldReturnItemCard(),
        ],
      ),
    );
  }
}

class ReturnItemCard extends StatefulWidget {
  @override
  _ReturnItemCardState createState() => _ReturnItemCardState();
}

class _ReturnItemCardState extends State<ReturnItemCard> {
  bool isReturning = false;
  bool isSubmitted = false;
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading:
                CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
            title: Text('paracetamol'),
            subtitle: Text('Quantity : 1'),
            trailing: isSubmitted
                ? ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('cancel',),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isReturning = true;
                      });
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Return',style: TextStyle(color: Colors.white)),
                  ),
          ),
          if (isReturning && !isSubmitted) ...[
            SizedBox(height: 15),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'write any reason',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                if (reasonController.text.isNotEmpty) {
                  setState(() {
                    isSubmitted = true;
                    isReturning = false;
                  });
                }
              },
              child: Text('Submit'),
            ),
          ],
          SizedBox(height: 10),
          ProcessTracker(),
        ],
      ),
    );
  }
}

class OldReturnItemCard extends StatelessWidget {
  const OldReturnItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(radius: 24, backgroundColor: Colors.grey[300]),
        title: Text('Eye drops'),
        subtitle: Text('Quantity : 1'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('completed', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class ProcessTracker extends StatelessWidget {
  const ProcessTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildStep('Step : 1', 'Collect the\nproduct\nfrom users'),
          buildStep('Step : 2', 'Verify the\nproduct'),
          buildStep('Step : 3', 'Refund to\nYour\naccount'),
        ],
      ),
    );
  }

  Widget buildStep(String title, String desc) {
    return Column(
      children: [
        Icon(Icons.check_circle_outline, size: 30),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(desc, textAlign: TextAlign.center),
      ],
    );
  }
}
