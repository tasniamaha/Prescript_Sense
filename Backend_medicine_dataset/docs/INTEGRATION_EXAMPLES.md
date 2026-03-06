/**
 * OCR Prescription Analysis Integration Examples
 * 
 * Examples of how to integrate the overdose detection API
 * with Flutter frontend, web, and other consumers
 */

// ============ DART/FLUTTER EXAMPLE ============

/*
// 1. Create a Dart model for API responses

import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineAnalysis {
  final String medicine;
  final String dosePattern;
  final double dailyDose;
  final double maxSafeDose;
  final String status;
  final String type;

  MedicineAnalysis({
    required this.medicine,
    required this.dosePattern,
    required this.dailyDose,
    required this.maxSafeDose,
    required this.status,
    required this.type,
  });

  factory MedicineAnalysis.fromJson(Map<String, dynamic> json) {
    return MedicineAnalysis(
      medicine: json['medicine'],
      dosePattern: json['dose_pattern'],
      dailyDose: json['daily_dose'].toDouble(),
      maxSafeDose: json['max_safe_dose'].toDouble(),
      status: json['status'],
      type: json['type'],
    );
  }
}

class PrescriptionAnalysisResponse {
  final List<MedicineAnalysis> analysis;
  final Map<String, dynamic> summary;
  final List<String>? notFoundOrInvalid;

  PrescriptionAnalysisResponse({
    required this.analysis,
    required this.summary,
    this.notFoundOrInvalid,
  });

  bool get hasOverdose {
    return analysis.any((med) => med.status == 'OVERDOSE');
  }

  int get overdoseCount {
    return analysis.where((med) => med.status == 'OVERDOSE').length;
  }

  factory PrescriptionAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PrescriptionAnalysisResponse(
      analysis: List<MedicineAnalysis>.from(
        json['analysis'].map((x) => MedicineAnalysis.fromJson(x))
      ),
      summary: json['summary'],
      notFoundOrInvalid: json['not_found_or_invalid'] != null
          ? List<String>.from(json['not_found_or_invalid'])
          : null,
    );
  }
}

// 2. Create a service class

class PrescriptionService {
  final String baseUrl;

  PrescriptionService({this.baseUrl = 'http://localhost:5000'});

  Future<PrescriptionAnalysisResponse> analyzePrescription(
    String prescriptionText,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/medicine/analyze-prescription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prescription_text': prescriptionText,
        }),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        return PrescriptionAnalysisResponse.fromJson(
          jsonDecode(response.body),
        );
      } else {
        throw Exception('Failed to analyze prescription: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing prescription: $e');
    }
  }
}

// 3. Use in a Flutter widget

class PrescriptionAnalysisWidget extends StatefulWidget {
  final String ocrText;

  const PrescriptionAnalysisWidget({required this.ocrText});

  @override
  State<PrescriptionAnalysisWidget> createState() =>
      _PrescriptionAnalysisWidgetState();
}

class _PrescriptionAnalysisWidgetState
    extends State<PrescriptionAnalysisWidget> {
  late PrescriptionService _service;
  late Future<PrescriptionAnalysisResponse> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _service = PrescriptionService();
    _analysisFuture = _service.analyzePrescription(widget.ocrText);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrescriptionAnalysisResponse>(
      future: _analysisFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;

        return Column(
          children: [
            // Show warning if overdose detected
            if (data.hasOverdose)
              Container(
                color: Colors.red.shade100,
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        '⚠️ Overdose risk detected in ${data.overdoseCount} medicine(s)',
                        style: TextStyle(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),

            // Summary
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('${data.summary['total_medicines']}'),
                      Text('Total'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${data.summary['safe_count']}',
                          style: TextStyle(color: Colors.green)),
                      Text('Safe'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${data.summary['overdose_count']}',
                          style: TextStyle(color: Colors.red)),
                      Text('Overdose'),
                    ],
                  ),
                ],
              ),
            ),

            // Medicine list
            Expanded(
              child: ListView.builder(
                itemCount: data.analysis.length,
                itemBuilder: (context, index) {
                  final med = data.analysis[index];
                  final isOverdose = med.status == 'OVERDOSE';

                  return Card(
                    color: isOverdose
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    child: ListTile(
                      leading: Icon(
                        isOverdose
                            ? Icons.dangerous
                            : Icons.check_circle,
                        color: isOverdose ? Colors.red : Colors.green,
                      ),
                      title: Text(med.medicine),
                      subtitle: Text(
                        '${med.dosePattern} → ${med.dailyDose}/${med.maxSafeDose}',
                      ),
                      trailing: Chip(
                        label: Text(med.status),
                        backgroundColor: isOverdose
                            ? Colors.red
                            : Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
*/

// ============ JAVASCRIPT/REACT EXAMPLE ============

/*
// 1. Create a hook for API calls

const usePrescriptionAnalysis = (baseUrl = 'http://localhost:5000') => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [data, setData] = useState(null);

  const analyze = async (prescriptionText) => {
    setLoading(true);
    setError(null);

    try {
      const response = await fetch(
        `${baseUrl}/api/medicine/analyze-prescription`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ prescription_text: prescriptionText }),
        }
      );

      if (!response.ok) {
        throw new Error(`API Error: ${response.statusCode}`);
      }

      const result = await response.json();
      setData(result);
      return result;
    } catch (err) {
      setError(err.message);
      throw err;
    } finally {
      setLoading(false);
    }
  };

  return { analyze, loading, error, data };
};

// 2. Use in a React component

function PrescriptionAnalyzer({ ocrText }) {
  const { analyze, loading, error, data } = usePrescriptionAnalysis();

  useEffect(() => {
    if (ocrText) {
      analyze(ocrText);
    }
  }, [ocrText]);

  if (loading) return <div>Analyzing prescription...</div>;
  if (error) return <div className="error">{error}</div>;
  if (!data) return null;

  const hasOverdose = data.analysis.some(med => med.status === 'OVERDOSE');

  return (
    <div className="prescription-analysis">
      {hasOverdose && (
        <div className="alert alert-danger">
          ⚠️ Overdose risk detected in {data.summary.overdose_count} medicine(s)
        </div>
      )}

      <div className="summary">
        <div>Total: {data.summary.total_medicines}</div>
        <div className="safe">Safe: {data.summary.safe_count}</div>
        <div className="overdose">
          Overdose: {data.summary.overdose_count}
        </div>
      </div>

      <div className="medicine-list">
        {data.analysis.map((med, idx) => (
          <div
            key={idx}
            className={`medicine-item ${med.status.toLowerCase()}`}
          >
            <span className="name">{med.medicine}</span>
            <span className="dose">{med.dose_pattern}</span>
            <span className="ratio">
              {med.daily_dose}/{med.max_safe_dose}
            </span>
            <span className={`status ${med.status.toLowerCase()}`}>
              {med.status}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
*/

// ============ PYTHON EXAMPLE ============

"""
import requests
import json
from typing import List, Dict, Optional

class PrescriptionAnalyzer:
    def __init__(self, base_url: str = 'http://localhost:5000'):
        self.base_url = base_url

    def analyze_prescription(self, prescription_text: str) -> Dict:
        '''
        Analyze prescription for overdoses
        '''
        try:
            response = requests.post(
                f'{self.base_url}/api/medicine/analyze-prescription',
                json={'prescription_text': prescription_text},
                timeout=30
            )
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            return {'error': str(e)}

    def has_overdose(self, analysis: Dict) -> bool:
        '''Check if prescription has overdose risk'''
        return any(med['status'] == 'OVERDOSE' 
                  for med in analysis.get('analysis', []))

    def get_overdose_medicines(self, analysis: Dict) -> List[Dict]:
        '''Get list of medicines with overdose risk'''
        return [med for med in analysis.get('analysis', []) 
               if med['status'] == 'OVERDOSE']

    def print_report(self, analysis: Dict):
        '''Print human-readable analysis report'''
        if 'error' in analysis:
            print(f"Error: {analysis['error']}")
            return

        summary = analysis['summary']
        print(f"\\nPrescription Analysis Report")
        print(f"{'='*40}")
        print(f"Total Medicines: {summary['total_medicines']}")
        print(f"Safe: {summary['safe_count']} ✓")
        print(f"Overdose Risk: {summary['overdose_count']} ⚠️")
        print(f"{'='*40}")

        for med in analysis['analysis']:
            status_icon = '✓' if med['status'] == 'SAFE' else '⚠️'
            print(f"{status_icon} {med['medicine']}: "
                  f"{med['daily_dose']}/{med['max_safe_dose']} units - "
                  f"{med['status']}")

# Usage example
if __name__ == '__main__':
    prescription_text = '''
    Name: John Doe
    Age: 45
    
    Tab Napa 1+0+1
    Cap Seclo 1+0+0
    Tab Ace 1+1+1
    '''

    analyzer = PrescriptionAnalyzer()
    result = analyzer.analyze_prescription(prescription_text)

    if analyzer.has_overdose(result):
        print("⚠️ OVERDOSE DETECTED!")
        for med in analyzer.get_overdose_medicines(result):
            print(f"  - {med['medicine']}")
    else:
        print("✓ Prescription is safe")

    analyzer.print_report(result)
"""

// ============ NODE.JS EXAMPLE (WITH EXPRESS MIDDLEWARE) ============

/*
const express = require('express');
const http = require('http');

// Middleware to analyze prescription before processing
const analyzePrescriptionMiddleware = async (req, res, next) => {
  if (req.body.prescription_text) {
    try {
      const response = await fetch('http://localhost:5000/api/medicine/analyze-prescription', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          prescription_text: req.body.prescription_text
        })
      });

      const analysisResult = await response.json();
      
      // Attach analysis to request
      req.prescriptionAnalysis = analysisResult;

      // If overdose detected, log warning
      if (analysisResult.analysis && 
          analysisResult.analysis.some(m => m.status === 'OVERDOSE')) {
        console.warn('⚠️ Overdose risk in prescription');
        res.locals.hasOverdose = true;
      }

      next();
    } catch (error) {
      console.error('Error analyzing prescription:', error);
      next(); // Continue even if analysis fails
    }
  } else {
    next();
  }
};

// Use middleware
app.use(express.json());
app.use(analyzePrescriptionMiddleware);

// Example route
app.post('/prescriptions', (req, res) => {
  const analysis = req.prescriptionAnalysis;

  if (analysis && res.locals.hasOverdose) {
    return res.status(400).json({
      error: 'Prescription contains overdose risk',
      details: analysis
    });
  }

  // Process prescription...
  res.json({ message: 'Prescription saved' });
});
*/

module.exports = {
  // This file is primarily for documentation/examples
  // Import and use the actual classes from your frontend/backend
};
