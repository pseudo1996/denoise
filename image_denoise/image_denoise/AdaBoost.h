#pragma once
#ifndef ADA_BOOST
#define ADA_BOOST 

#include <vector>
#include <algorithm>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>


using std::vector;
using cv::Mat;

struct matched_patch {
	int xpos;
	int ypos;
	double distance;
};

inline bool operator<(const matched_patch& mp1, const matched_patch& mp2) {
	return mp1.distance < mp2.distance;
};

inline std::ostream& operator<<(std::ostream& out, const matched_patch& mp) {

	return out << "xpos: " << mp.xpos << '\t' << "ypos: " << mp.ypos << '\t' << "dist: " << mp.distance << '\n';

}

vector<matched_patch> block_match(const Mat&, int, const Mat&, int, int);

Mat group(const Mat&, const vector<matched_patch>&, int, int);

Mat solve_wnnm(const Mat&, double, double, double);

Mat aggregate(const Mat&, const Mat&, double, int);

double cal_rhoK(const Mat&, const Mat&, double, double);

double cal_var(const Mat&);

#endif